From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Mon, 14 Mar 2016 20:07:41 +0000
Subject: [lustre-devel]
 linux-4.5/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c:880: wrong %
 specifier ?
In-Reply-To: <DUB128-W424197BF214665EBD6F6C39C880@phx.gbl>
References: <DUB128-W424197BF214665EBD6F6C39C880@phx.gbl>
Message-ID: <E9028481-4DFE-40AD-8714-11EBC1127138@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Previously GCC didn't care about the distinction between %d and %u, so I suspect there are a large number of such warnings that need to be repaired. 

Cheers, Andreas

> On Mar 14, 2016, at 13:36, David Binderman <dcb314@hotmail.com> wrote:
> 
> Hello there,
> 
> [linux-4.5/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c:880]: (warning) %d in format string (no. 1) requires 'int' but the argument type is 'unsigned int'.    
> 
> Source code is
> 
>     return sprintf(buf, "%d\n", ldlm_cancel_unused_locks_before_replay);
> 
> but
> 
> extern unsigned int ldlm_cancel_unused_locks_before_replay;
> 
> Suggest use %u, not %d.
> 
> 
> Regards
> 
> David Binderman
>                         
