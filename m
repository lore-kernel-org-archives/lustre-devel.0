From: Alexey Lyashkov <alexey.lyashkov@clusterstor.com>
Date: Thu, 15 Jul 2010 22:25:18 +0300
Subject: [Lustre-devel] async write and abort_recov
In-Reply-To: <4C3F5A2F.2010105@ices.utexas.edu>
References: <4C3AE9FC.5010705@cea.fr>	<4EC6AD38-0BE5-4DDC-B98A-C1C835292305@oracle.com>	<4C3EC133.2030800@cea.fr>
	<F8ED1D1B-A853-4C8B-8236-9CC514EF8F52@oracle.com>
	<4C3F5A2F.2010105@ices.utexas.edu>
Message-ID: <3DE7FAF4-8978-4F13-8AED-F43B8136705E@clusterstor.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Jul 15, 2010, at 21:57, John Hammond wrote:

> On 07/15/2010 11:19 AM, Andreas Dilger wrote:
>> On 2010-07-15, at 02:05, Aurelien Degremont wrote:
>>> Andreas Dilger a ?crit :
>>>> While I know Lustre will save errors from async write RPCs into
>>>> the file descriptor for later write calls or fsync), I don't know
>>>> if we save any IO error into the file descriptor if we discard
>>>> pages due to eviction.  I think only errors due to currently
>>>> in-flight RPCs that are aborted due to client eviction are
>>>> returned.
> 
> If the async write fails due to eviction then writepage() will store 
> -ESHUTDOWN in the inode info's lli_async_rc member.
no sure. look to ll_ap_completion to correct error reporting.

        } else {                                                                                                
                if (cmd & OBD_BRW_READ) {                                                                       
                        llap->llap_defer_uptodate = 0;                                                          
                }                                                                                               
                SetPageError(page);                                                                             
                if (rc == -ENOSPC)                                                                              
                        set_bit(AS_ENOSPC, &page->mapping->flags);                                              
                else                                                                                            
                        set_bit(AS_EIO, &page->mapping->flags);                                                 
        }                                                                                                       

but that codepath never called if client has dirty data, but async IO don't started.
in that case, client canceled owned locks with local + discard flags set, so ll_page_removal_cb called with discard flag set and error bit don't set in mapping.



--------------------------------------
Alexey Lyashkov
alexey.lyashkov at clusterstor.com
