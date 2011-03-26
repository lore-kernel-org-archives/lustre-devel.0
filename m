From: wangdi <di.wang@whamcloud.com>
Date: Fri, 25 Mar 2011 17:05:57 -0700
Subject: [Lustre-devel] The good usage of lustre *_thread_info structure
In-Reply-To: <4D8D16E6.8050708@cea.fr>
References: <4D8D16E6.8050708@cea.fr>
Message-ID: <4D8D2DE5.30209@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 03/25/2011 03:27 PM, Aur?lien Degr?mont wrote:
> Hello
>
> Doing some coding in Lustre, I'm wondering for a while was it the
> correct usage of thread_info structure like mdt_thread_info or
> mdd_thread_info.
> They contain pre-allocated data or pointer to pass this between function
> call and layer without overloading the stack.
> My concern is: if a function decide to use of them to store some of its
> data, how can it be sure that it was not used by an upper layer or a
> calling function?
> How can I be sure it is safe to use them?

This thread_info will be initialized in the beginning of the request 
handling (ptlrpc_server_handle_request -> lu_context_init, and attached 
to the request), and currently the request will only be processed by a 
single thread, i.e. no other threads will try to access the request and 
the thread info. so it is safe to use this  info within the service thread.

This thread_info is actually designed for providing large temporary 
memory to functions, so they can get these memories in a cheap way, 
instead of allocating/freeing every time or reserving large tmp var in 
the stack. Each layer has its own thread info,  it should not be 
accessed by different layers.

Thanks
WangDi
> By example :
>
> struct mdt_thread_info {
>      ...
>           /*
>            * Object attributes.
>            */
>           struct md_attr             mti_attr;
>       ...
> }
>
> A function in MDT layer could decide it will use this structure
> (mti_attr) for its own need, then it will call several functions that
> could have the same need. How can those functions know that they can or
> cannot re-use this structure? Same issues for pointers.
>
> Thanks for any help
>
> Aur?lien
>
>
>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
