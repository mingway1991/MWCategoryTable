//
//  CallStack.m
//  Lvmm
//
//  Created by 石茗伟 on 2019/5/20.
//  Copyright © 2019 Lvmama. All rights reserved.
//

// 参考文章 https://bestswifter.com/callstack/

#import "CallStack.h"
#import <pthread.h>
#include <sys/types.h>
#include <dlfcn.h>
#include <limits.h>
#include <string.h>
#include <mach-o/dyld.h>
#include <mach-o/nlist.h>

#if defined(__LP64__)
#define POINTER_FMT       "0x%016lx"
#define POINTER_SHORT_FMT "0x%lx"
#define MW_NLIST struct nlist_64
#else
#define POINTER_FMT       "0x%08lx"
#define POINTER_SHORT_FMT "0x%lx"
#define MW_NLIST struct nlist
#endif

typedef struct MWStackFrameEntry{
    const struct MWStackFrameEntry *const previous;
    const uintptr_t return_address;
} MWStackFrameEntry;

// 符号化
kern_return_t bs_mach_copyMem(const void *const src, void *const dst, const size_t numBytes) {
    vm_size_t bytesCopied = 0;
    return vm_read_overwrite(mach_task_self(), (vm_address_t)src, (vm_size_t)numBytes, (vm_address_t)dst, &bytesCopied);
}

#pragma -mark Symbolicate
uintptr_t bs_firstCmdAfterHeader(const struct mach_header* const header) {
    switch(header->magic) {
        case MH_MAGIC:
        case MH_CIGAM:
            return (uintptr_t)(header + 1);
        case MH_MAGIC_64:
        case MH_CIGAM_64:
            return (uintptr_t)(((struct mach_header_64*)header) + 1);
        default:
            return 0;  // Header is corrupt
    }
}

uint32_t bs_imageIndexContainingAddress(const uintptr_t address) {
    const uint32_t imageCount = _dyld_image_count();
    const struct mach_header* header = 0;
    
    for(uint32_t iImg = 0; iImg < imageCount; iImg++) {
        header = _dyld_get_image_header(iImg);
        if(header != NULL) {
            // Look for a segment command with this address within its range.
            uintptr_t addressWSlide = address - (uintptr_t)_dyld_get_image_vmaddr_slide(iImg);
            uintptr_t cmdPtr = bs_firstCmdAfterHeader(header);
            if(cmdPtr == 0) {
                continue;
            }
            for(uint32_t iCmd = 0; iCmd < header->ncmds; iCmd++) {
                const struct load_command* loadCmd = (struct load_command*)cmdPtr;
                if(loadCmd->cmd == LC_SEGMENT) {
                    const struct segment_command* segCmd = (struct segment_command*)cmdPtr;
                    if(addressWSlide >= segCmd->vmaddr &&
                       addressWSlide < segCmd->vmaddr + segCmd->vmsize) {
                        return iImg;
                    }
                }
                else if(loadCmd->cmd == LC_SEGMENT_64) {
                    const struct segment_command_64* segCmd = (struct segment_command_64*)cmdPtr;
                    if(addressWSlide >= segCmd->vmaddr &&
                       addressWSlide < segCmd->vmaddr + segCmd->vmsize) {
                        return iImg;
                    }
                }
                cmdPtr += loadCmd->cmdsize;
            }
        }
    }
    return UINT_MAX;
}

uintptr_t bs_segmentBaseOfImageIndex(const uint32_t idx) {
    const struct mach_header* header = _dyld_get_image_header(idx);
    
    // Look for a segment command and return the file image address.
    uintptr_t cmdPtr = bs_firstCmdAfterHeader(header);
    if(cmdPtr == 0) {
        return 0;
    }
    for(uint32_t i = 0;i < header->ncmds; i++) {
        const struct load_command* loadCmd = (struct load_command*)cmdPtr;
        if(loadCmd->cmd == LC_SEGMENT) {
            const struct segment_command* segmentCmd = (struct segment_command*)cmdPtr;
            if(strcmp(segmentCmd->segname, SEG_LINKEDIT) == 0) {
                return segmentCmd->vmaddr - segmentCmd->fileoff;
            }
        }
        else if(loadCmd->cmd == LC_SEGMENT_64) {
            const struct segment_command_64* segmentCmd = (struct segment_command_64*)cmdPtr;
            if(strcmp(segmentCmd->segname, SEG_LINKEDIT) == 0) {
                return (uintptr_t)(segmentCmd->vmaddr - segmentCmd->fileoff);
            }
        }
        cmdPtr += loadCmd->cmdsize;
    }
    return 0;
}

bool bs_dladdr(const uintptr_t address, Dl_info* const info) {
    info->dli_fname = NULL;
    info->dli_fbase = NULL;
    info->dli_sname = NULL;
    info->dli_saddr = NULL;
    
    const uint32_t idx = bs_imageIndexContainingAddress(address);
    if(idx == UINT_MAX) {
        return false;
    }
    const struct mach_header* header = _dyld_get_image_header(idx);
    const uintptr_t imageVMAddrSlide = (uintptr_t)_dyld_get_image_vmaddr_slide(idx);
    const uintptr_t addressWithSlide = address - imageVMAddrSlide;
    const uintptr_t segmentBase = bs_segmentBaseOfImageIndex(idx) + imageVMAddrSlide;
    if(segmentBase == 0) {
        return false;
    }
    
    info->dli_fname = _dyld_get_image_name(idx);
    info->dli_fbase = (void*)header;
    
    // Find symbol tables and get whichever symbol is closest to the address.
    const MW_NLIST* bestMatch = NULL;
    uintptr_t bestDistance = ULONG_MAX;
    uintptr_t cmdPtr = bs_firstCmdAfterHeader(header);
    if(cmdPtr == 0) {
        return false;
    }
    for(uint32_t iCmd = 0; iCmd < header->ncmds; iCmd++) {
        const struct load_command* loadCmd = (struct load_command*)cmdPtr;
        if(loadCmd->cmd == LC_SYMTAB) {
            const struct symtab_command* symtabCmd = (struct symtab_command*)cmdPtr;
            const MW_NLIST* symbolTable = (MW_NLIST*)(segmentBase + symtabCmd->symoff);
            const uintptr_t stringTable = segmentBase + symtabCmd->stroff;
            
            for(uint32_t iSym = 0; iSym < symtabCmd->nsyms; iSym++) {
                // If n_value is 0, the symbol refers to an external object.
                if(symbolTable[iSym].n_value != 0) {
                    uintptr_t symbolBase = symbolTable[iSym].n_value;
                    uintptr_t currentDistance = addressWithSlide - symbolBase;
                    if((addressWithSlide >= symbolBase) &&
                       (currentDistance <= bestDistance)) {
                        bestMatch = symbolTable + iSym;
                        bestDistance = currentDistance;
                    }
                }
            }
            if(bestMatch != NULL) {
                info->dli_saddr = (void*)(bestMatch->n_value + imageVMAddrSlide);
                info->dli_sname = (char*)((intptr_t)stringTable + (intptr_t)bestMatch->n_un.n_strx);
                if(*info->dli_sname == '_') {
                    info->dli_sname++;
                }
                // This happens if all symbols have been stripped.
                if(info->dli_saddr == info->dli_fbase && bestMatch->n_type == 3) {
                    info->dli_sname = NULL;
                }
                break;
            }
        }
        cmdPtr += loadCmd->cmdsize;
    }
    return true;
}

void bs_symbolicate(const uintptr_t* const backtraceBuffer,
                    Dl_info* const symbolsBuffer,
                    const int numEntries,
                    const int skippedEntries){
    int i = 0;
    
    if(!skippedEntries && i < numEntries) {
        bs_dladdr(backtraceBuffer[i], &symbolsBuffer[i]);
        i++;
    }
    
    for(; i < numEntries; i++) {
        uintptr_t address;
#if defined(__arm64__)
        address = (((backtraceBuffer[i]) & ~(3UL)) - 1);
#elif defined(__arm__)
        address = (((backtraceBuffer[i]) & ~(1UL)) - 1);
#elif defined(__x86_64__)
        address = ((backtraceBuffer[i]) - 1);
#elif defined(__i386__)
        address = ((backtraceBuffer[i]) - 1);
#endif
        bs_dladdr(address, &symbolsBuffer[i]);
    }
}

#pragma mark - Log
const char* bs_lastPathEntry(const char* const path) {
    if(path == NULL) {
        return NULL;
    }
    
    char* lastFile = strrchr(path, '/');
    return lastFile == NULL ? path : lastFile + 1;
}

NSArray* bs_logBacktraceEntry(const int entryNum,
                               const uintptr_t address,
                               const Dl_info* const dlInfo) {
    char faddrBuff[20];
    char saddrBuff[20];
    
    const char* fname = bs_lastPathEntry(dlInfo->dli_fname);
    if(fname == NULL) {
        sprintf(faddrBuff, POINTER_FMT, (uintptr_t)dlInfo->dli_fbase);
        fname = faddrBuff;
    }
    
    uintptr_t offset = address - (uintptr_t)dlInfo->dli_saddr;
    const char* sname = dlInfo->dli_sname;
    if(sname == NULL) {
        sprintf(saddrBuff, POINTER_SHORT_FMT, (uintptr_t)dlInfo->dli_fbase);
        sname = saddrBuff;
        offset = address - (uintptr_t)dlInfo->dli_fbase;
    }
    return @[[NSString stringWithFormat:@"%-30s",fname],
             [NSString stringWithFormat:@"0x%08" PRIxPTR "", (uintptr_t)address],
             [NSString stringWithFormat:@"%s",sname],
             [NSString stringWithFormat:@"%lu", offset]];
}

@implementation CallStackItem


@end

@implementation CallStackInfo


@end

static mach_port_t main_thread_id;

@implementation CallStack

#pragma mark - Public
- (CallStackInfo *)getCallStackInfo:(NSThread *)nsthread {
    thread_t thread = mw_machThreadFromNSThread(nsthread);
    _STRUCT_MCONTEXT context; // 存储了当前线程的 Stack Pointer 和最顶部栈帧的 Frame Pointer，从而获取到了整个线程的调用栈
    thread_state_flavor_t threadState;
    mach_msg_type_number_t threadStateCount;
#if defined(__arm64__)
    threadState = ARM_THREAD_STATE64;
    threadStateCount = ARM_THREAD_STATE64_COUNT;
#elif defined(__arm__)
    threadState = ARM_THREAD_STATE;
    threadStateCount = ARM_THREAD_STATE_COUNT;
#elif defined(__x86_64__)
    threadState = x86_THREAD_STATE64;
    threadStateCount = x86_THREAD_STATE64_COUNT;
#elif defined(__i386__)
    threadState = x86_THREAD_STATE32;
    threadStateCount = x86_THREAD_STATE32_COUNT;
#endif
    // threadState和threadStateCount依赖cpu架构，通过thread_get_state获取到的信息填充到context中
    kern_return_t kr = thread_get_state(thread, threadState, (thread_state_t)&context.__ss, &threadStateCount);
    if (kr == KERN_SUCCESS) {
        uintptr_t instructionAddress;
        uintptr_t framePointer;
        uintptr_t linkRegister;
#if defined(__arm64__)
        instructionAddress = context.__ss.__pc;
        framePointer = context.__ss.__fp;
        linkRegister = context.__ss.__lr;
#elif defined(__arm__)
        instructionAddress = context.__ss.__pc;
        framePointer = context.__ss.__r[7];
        linkRegister = context.__ss.__lr;
#elif defined(__x86_64__)
        instructionAddress = context.__ss.__rip;
        framePointer = context.__ss.__rbp;
        linkRegister = 0;
#elif defined(__i386__)
        instructionAddress = context.__ss.__eip;
        framePointer = context.__ss.__ebp;
        linkRegister = 0;
#endif
        if(instructionAddress == 0) {
            // 拿不到instructionAddress，直接退出
            return nil;
        }
        
        if (framePointer == 0) {
            // 拿不到framePointer，直接退出
            return nil;
        }
        
        long maxLength = 50;
        uintptr_t backtraceBuffer[maxLength];
        int i = 0;
        backtraceBuffer[i] = instructionAddress;
        ++i;
        
        if (linkRegister) {
            backtraceBuffer[i] = linkRegister;
            i++;
        }
        
        MWStackFrameEntry frame = {0};
        if (bs_mach_copyMem((void *)framePointer, &frame, sizeof(frame)) != KERN_SUCCESS) {
            return nil;
        }
        
        for (; i < maxLength; i++) {
            backtraceBuffer[i] = frame.return_address;
            if (backtraceBuffer[i] == 0 || frame.previous == 0 || bs_mach_copyMem(frame.previous, &frame, sizeof(frame)) != KERN_SUCCESS) {
                break;
            }
        }
        
        int backtraceLength = i;
        Dl_info symbolicated[backtraceLength];
        bs_symbolicate(backtraceBuffer, symbolicated, backtraceLength, 0);
        NSMutableArray *items = [NSMutableArray array];
        for (int i = 0; i < backtraceLength; ++i) {
            NSArray *logs = bs_logBacktraceEntry(i, backtraceBuffer[i], &symbolicated[i]);
            CallStackItem *item = [[CallStackItem alloc] init];
            item.fname= logs[0];
            item.address= logs[1];
            item.sname= logs[2];
            item.offset= logs[3];
            [items addObject:item];
        }
        CallStackInfo *info = [[CallStackInfo alloc] init];
        info.thread = thread;
        info.items = items;
        return info;
    } else {
        return nil;
    }
}

#pragma mark - Load
+ (void)load {
    main_thread_id = mach_thread_self();
}

#pragma mark - NSThread to thread_t
/*
 nsthread 转 thread_t
 
 实现思路：
 NSThread 参数，把它的名字改为某个随机数(我选择了时间戳)，然后遍历 pthread 并检查有没有匹配的名字。查找完成后把参数的名字恢复即可。
 注：主线程设置 name 后无法用 pthread_getname_np 读取到。所以在load方法中保存了主线程thread_t
 */
thread_t mw_machThreadFromNSThread(NSThread *nsthread) {
    if ([nsthread isMainThread]) {
        return (thread_t)main_thread_id;
    }
    
    char name[256];
    mach_msg_type_number_t count;
    thread_act_array_t list;
    task_threads(mach_task_self(), &list, &count); // 获取所有线程
    
    // 保存原始nsthread name
    NSString *originName = [nsthread name];
    // 将nsthread name改为一个随机名称
    [nsthread setName:[NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]]];
    
    for (int i = 0; i < count; ++i) {
        pthread_t pt = pthread_from_mach_thread_np(list[i]);
        if (pt) {
            name[0] = '\0';
            pthread_getname_np(pt, name, sizeof name);
            if (!strcmp(name, [nsthread name].UTF8String)) {
                // 比对名字为刚刚设的thread则为需要找到的
                [nsthread setName:originName];
                return list[i];
            }
        }
    }
    
    [nsthread setName:originName]; // nsthread恢复原始name
    return mach_thread_self();
}

@end
