From: Andreas Dilger <adilger@sun.com>
Date: Tue, 22 Dec 2009 16:49:51 -0700
Subject: [Lustre-devel] lustre configure error when compile
In-Reply-To: <B20C2B25-CD9E-4F83-89AD-2E24F5001690@earthlink.net>
References: <200912221752285466212@sohu.com>
	<B20C2B25-CD9E-4F83-89AD-2E24F5001690@earthlink.net>
Message-ID: <09190CAE-4B0A-4770-BD31-4C3EBAF7C6DC@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2009-12-22, at 03:41, Mitchell Erblich wrote:
> 		This is probably wrong as it is the fastest answer.
> 		Identify what name / release. Redhat, SuSE, SELES, etc..
> 		Goto kernel.org..
> 		See if xattr_acl.h is present and if so, copy it in and 		rerun  
> configure.

Sorry, but this is indeed the completely wrong answer.  The fact that  
xattr_acl.h is missing is not in itself a problem.

> On Dec 22, 2009, at 1:52 AM, ??? wrote:
>> 	checking for /usr/src/kernels/linux-2.6.18-128.1.14/include/linux/
>> xattr_acl.h... no
>> 	checking for /usr/src/kernels/linux-2.6.18-128.1.14/include/linux/
>> posix_acl_xattr.h... yes
>> 	checking if linux/posix_acl_xattr.h can be compiled... yes
>> 	checking calc acl size... configure: error: ACL size can't computed


What version of Lustre are you trying to compile?

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
