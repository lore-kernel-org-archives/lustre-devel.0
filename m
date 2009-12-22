From: Mitchell Erblich <erblichs@earthlink.net>
Date: Tue, 22 Dec 2009 02:41:18 -0800
Subject: [Lustre-devel] lustre configure error when compile
In-Reply-To: <200912221752285466212@sohu.com>
References: <200912221752285466212@sohu.com>
Message-ID: <B20C2B25-CD9E-4F83-89AD-2E24F5001690@earthlink.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Group,

		This is probably wrong as it is the fastest answer.

		Identify what name / release. Redhat, SuSE, SELES, etc..

		Goto kernel.org..

		See if xattr_acl.h is present and if so, copy it in and rerun  
configure.

		Report results..

		Mitchell Erblich
		=================


On Dec 22, 2009, at 1:52 AM, ??? wrote:

> Hello All
> 	checking for /usr/src/kernels/linux-2.6.18-128.1.14/include/linux/ 
> xattr_acl.h... no
> 	checking for /usr/src/kernels/linux-2.6.18-128.1.14/include/linux/ 
> posix_acl_xattr.h... yes
> 	checking if linux/posix_acl_xattr.h can be compiled... yes
> 	checking calc acl size... configure: error: ACL size can't computed
> this is configure results,please help me to resolve it
> thanks
> Best Regards
>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
