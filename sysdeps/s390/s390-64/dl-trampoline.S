/* PLT trampolines.  s390 version.
   Copyright (C) 2005 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
   02111-1307 USA.  */

/* The PLT stubs will call _dl_runtime_resolve/_dl_runtime_profile
 * with the following linkage:
 *   r2 - r6 : parameter registers
 *   f0, f2, f4, f6 : floating point parameter registers
 *   24(r15), 28(r15) : PLT arguments PLT1, PLT2
 *   96(r15) : additional stack parameters
 * The normal clobber rules for function calls apply:
 *   r0 - r5 : call clobbered
 *   r6 - r13 :	 call saved
 *   r14 : return address (call clobbered)
 *   r15 : stack pointer (call saved)
 *   f1, f3, f5, f7 : call saved
 *   f0 - f3, f5, f7 - f15 : call clobbered
 */

#include <sysdep.h>

	.text
	.globl _dl_runtime_resolve
	.type _dl_runtime_resolve, @function
	cfi_startproc
	.align 16
_dl_runtime_resolve:
	stmg   2,5,64(15)	# save registers
	stg    14,96(15)
	cfi_offset (r14, -64)
	lgr    0,15		# create stack frame
	aghi   15,-160
	cfi_adjust_cfa_offset (160)
	stg    0,0(15)
	lmg    2,3,208(15)	# load args saved by PLT
	brasl  14,_dl_fixup	# call fixup
	lgr    1,2		# function addr returned in r2
	aghi   15,160		# remove stack frame
	cfi_adjust_cfa_offset (-160)
	lg     14,96(15)	# restore registers
	lmg    2,5,64(15)
	br     1
	cfi_endproc
	.size _dl_runtime_resolve, .-_dl_runtime_resolve


#ifndef PROF
	.globl _dl_runtime_profile
	.type _dl_runtime_profile, @function
	cfi_startproc
	.align 16
_dl_runtime_profile:
	stmg   %r2,%r6,64(%r15)		# save registers
	std    %f0,104(%r15)
	std    %f2,112(%r15)
	std    %f4,120(%r15)
	std    %f6,128(%r15)
	stg    %r6,16(%r15)
	stg    %r12,24(%r15)
	stg    %r14,32(%r15)
	cfi_offset (r6, -96)
	cfi_offset (f0, -56)
	cfi_offset (f2, -48)
	cfi_offset (f4, -40)
	cfi_offset (f6, -32)
	cfi_offset (r12, -136)
	cfi_offset (r14, -128)
	lgr    %r12,%r15		# create stack frame
	cfi_def_cfa_register (12)
	aghi   %r15,-160
	stg    %r12,0(%r15)
	lmg    %r2,%r3,48(%r12)		# load arguments saved by PLT
	lgr    %r4,%r14			# return address as third parameter
	la     %r5,64(%r12)		# pointer to struct La_s390_32_regs
	la     %r6,40(%r12)		# long int * framesize
	brasl  %r14,_dl_profile_fixup	# call resolver
	lgr    %r1,%r2			# function addr returned in r2
	lg     %r0,40(%r12)		# load framesize
	ltgr   %r0,%r0
	jnm    1f
	lmg    %r2,%r6,64(%r12)
	ld     %f0,104(%r12)
	ld     %f2,112(%r12)
	ld     %f4,120(%r12)
	ld     %f6,128(%r12)
	basr   %r14,%r1			# call resolved function
0:	lgr    %r15,%r12		# remove stack frame
	cfi_def_cfa_register (15)
	lg     %r14,32(%r15)		# restore registers
	lg     %r12,24(%r15)
	lg     %r6,16(%r15)
	br     %r14
	cfi_def_cfa_register (12)
1:	jz     4f			# framesize == 0 ?
	aghi   %r0,7			# align framesize to 8
	nill   %r0,0xfff8
	slgr   %r15,%r0			# make room for framesize bytes
	stg    %r12,0(%r15)
	la     %r2,160(%r15)
	la     %r3,160(%r12)
	srlg   %r0,%r0,3
3:	mvc    0(8,%r2),0(%r3)		# copy additional parameters
	la     %r2,8(%r2)
	la     %r3,8(%r3)
	brctg  %r0,3b
4:	lmg    %r2,%r6,64(%r12)		# load register parameters
	ld     %f0,104(%r12)
	ld     %f2,112(%r12)
	ld     %f4,120(%r12)
	ld     %f6,128(%r12)
	basr   %r14,%r1			# call resolved function
	stg    %r2,136(%r12)
	std    %f0,144(%r12)
	lmg    %r2,%r3,48(%r12)		# load arguments saved by PLT
	la     %r4,32(%r12)		# pointer to struct La_s390_32_regs
	la     %r5,72(%r12)		# pointer to struct La_s390_32_retval
	brasl  %r14,_dl_call_pltexit
	j      0b
	cfi_endproc
	.size _dl_runtime_profile, .-_dl_runtime_profile
#endif
