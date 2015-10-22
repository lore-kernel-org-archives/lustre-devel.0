From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Thu, 22 Oct 2015 16:10:22 +0000
Subject: [lustre-devel] layout.c capsule dumps
In-Reply-To: <D24E7FDD.2745%jevans@cray.com>
References: <D24E7FDD.2745%jevans@cray.com>
Message-ID: <6BD451EE-8F63-4343-BA8B-1CDB87462270@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

They are only for debugging. Probably best to put them under CONFIG_DEBUG_LUSTRE_EXPENSIVE_CHECKS or some new CONFIG option. 

Cheers, Andreas

> On Oct 22, 2015, at 09:58, Ben Evans <bevans@cray.com> wrote:
> 
> Are these completely unused at this point?  As far as I can tell, the main mechanism to dump info, req_capsule_(client|server)_dump are completely unreferenced by anything.
> 
> Would it make sense to remove all this as dead code, or am I missing something?
> 
> -Ben Evans
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
