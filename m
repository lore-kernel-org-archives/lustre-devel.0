From: Eric Mei <Eric.Mei@Sun.COM>
Date: Fri, 20 Jun 2008 10:13:52 -0600
Subject: [Lustre-devel] GSS cross-realm broken in lsvcgssd
In-Reply-To: <485B2F33.2020608@psc.edu>
References: <485B2F33.2020608@psc.edu>
Message-ID: <485BD740.3090500@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello Ben,

Benjamin Bennett wrote:
> lsvcgssd from the current HEAD refuses all remote-realm principals, the 
> culprit is get_ids() in lustre/utils/gss/svcgssd_proc.c
> 
> In the previous revision (1.4):
>   MDS accepts remote principals with mapping to local user.
>   OSS accepts remote "lustre_root at SOMEREALM" principals.
>   Any other remote principals are logged as unmapped and failed.
> 
> In the current revision (1.5, since Jan):
>   MDS fails all remote principals.
>   OSS fails all remote principals.
>   Unmapped remote principals are logged, mapped are not.
> 
> The attached patch (against 1.5):
>   Restores previous MDS behavior of accepting remote principals with 
> mapping to local user.
>   Modifies OSS behavior to accept remote "lustre_root at SOMEREALM" and 
> "lustre_root/hostname at SOMEREALM" principals.
>   Fixes logging errors in get_ids().

We didn't really tested cross-realm cases. The patch looks great, we'll 
merge it into our CVS asap. Thanks a lot!

-- 
Eric
