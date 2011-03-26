From: =?ISO-8859-1?Q?Aur=E9lien_Degr=E9mont?= <aurelien.degremont@cea.fr>
Date: Sat, 26 Mar 2011 15:22:25 +0100
Subject: [Lustre-devel] The good usage of lustre *_thread_info structure
In-Reply-To: <4D8D2DE5.30209@whamcloud.com>
References: <4D8D16E6.8050708@cea.fr> <4D8D2DE5.30209@whamcloud.com>
Message-ID: <4D8DF6A1.8000004@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Le 26/03/2011 01:05, wangdi said:
> This thread_info will be initialized in the beginning of the request
> handling (ptlrpc_server_handle_request ->  lu_context_init, and attached
> to the request), and currently the request will only be processed by a
> single thread, i.e. no other threads will try to access the request and
> the thread info. so it is safe to use this  info within the service thread.
>
> This thread_info is actually designed for providing large temporary
> memory to functions, so they can get these memories in a cheap way,
> instead of allocating/freeing every time
To be sure, what is the bad aspect we want to avoid here?


Le 26/03/2011 08:52, Nikita Danilov said:
> For the call chains within a layer it is up to the programmer to ascertain that the same element of lu_env::le_ctx is not re-used improperly. To some extent this can be done automatically, e.g., by introducing an interface to access sub-structures in struct mdt_thread_info, which would maintain a "busy" flag and check it on access.
So it is rather a DIY :)

If I take an example :

mdd_thread_info.mti_xattr_buf

is there to be used when reading/changing a XATTR. If I code an helper 
method in MDD which needs to manipulate an XATTR, this field looks 
really interesting. But, I do not know for sure that all callers we not 
be using it? So the only solution is that I verify each of them are not 
using it (and their callers)? And latter, if someone add a new way to 
call my method, he must looks for what stuff i'm using in the 
thread_info to be sure it does not conflict with what he currently uses? 
This seems a lot of code to check...


And so, how can I chose that this field is relevant to be added to 
thread_info instead of allocating/freeing it inside my function?


Thanks for both your help

Aur?lien
