/* This file contains a number of internal prototype declarations that
   don't fit anywhere else.  */

#ifndef _LIBC_INTERNAL
# define _LIBC_INTERNAL 1

#include <hp-timing.h>

/* Initialize the `__libc_enable_secure' flag.  */
extern void __libc_init_secure (void);

/* This function will be called from _init in init-first.c.  */
extern void __libc_global_ctors (void);

/* Discover the tick frequency of the machine if something goes wrong,
   we return 0, an impossible hertz.  */
extern int __profile_frequency (void);
libc_hidden_proto (__profile_frequency)

/* Hooks for the instrumenting functions.  */
extern void __cyg_profile_func_enter (void *this_fn, void *call_site);
extern void __cyg_profile_func_exit (void *this_fn, void *call_site);

/* Get frequency of the system processor.  */
extern hp_timing_t __get_clockfreq (void);

/* Free all allocated resources.  */
extern void __libc_freeres (void);
libc_hidden_proto (__libc_freeres)

/* Free resources stored in thread-local variables on thread exit.  */
extern void __libc_thread_freeres (void);

/* Define and initialize `__progname' et. al.  */
extern void __init_misc (int, char **, char **);

/* Align a value by rounding down to closest size.
   e.g. Using size of 4096, we get this behavior:
	{4095, 4096, 4097} = {0, 4096, 4096}.  */
#define ALIGN_DOWN(base, size)	((base) & -((__typeof__ (base)) (size)))

/* Align a value by rounding up to closest size.
   e.g. Using size of 4096, we get this behavior:
	{4095, 4096, 4097} = {4096, 4096, 8192}.

  Note: The size argument has side effects (expanded multiple times).  */
#define ALIGN_UP(base, size)	ALIGN_DOWN ((base) + (size) - 1, (size))

/* Same as ALIGN_DOWN(), but automatically casts when base is a pointer.  */
#define PTR_ALIGN_DOWN(base, size) \
  ((__typeof__ (base)) ALIGN_DOWN ((uintptr_t) (base), (size)))

/* Same as ALIGN_UP(), but automatically casts when base is a pointer.  */
#define PTR_ALIGN_UP(base, size) \
  ((__typeof__ (base)) ALIGN_UP ((uintptr_t) (base), (size)))

#endif /* _LIBC_INTERNAL  */
