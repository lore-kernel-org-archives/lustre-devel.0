From: Nikita Danilov <Nikita_Danilov@xyratex.com>
Date: Sat, 26 Mar 2011 07:38:46 -0700
Subject: [Lustre-devel] The good usage of lustre *_thread_info structure
In-Reply-To: <4D8DF6A1.8000004@cea.fr>
References: <4D8D16E6.8050708@cea.fr> <4D8D2DE5.30209@whamcloud.com>
	<4D8DF6A1.8000004@cea.fr>
Message-ID: <73AED5C780AE05478241DB067651A92102000E2C@XYUS-EX22.xyus.xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Mar 26, 2011, at 17:22 , Aur?lien Degr?mont wrote:

> Le 26/03/2011 01:05, wangdi said:
>> This thread_info will be initialized in the beginning of the request
>> handling (ptlrpc_server_handle_request ->  lu_context_init, and attached
>> to the request), and currently the request will only be processed by a
>> single thread, i.e. no other threads will try to access the request and
>> the thread info. so it is safe to use this  info within the service thread.
>> 
>> This thread_info is actually designed for providing large temporary
>> memory to functions, so they can get these memories in a cheap way,
>> instead of allocating/freeing every time
> To be sure, what is the bad aspect we want to avoid here?

Kernel stack space is severely limited (4KB or 8KB) and dynamic memory allocation is too expensive for some  paths.

> 
> 
> Le 26/03/2011 08:52, Nikita Danilov said:
>> For the call chains within a layer it is up to the programmer to ascertain that the same element of lu_env::le_ctx is not re-used improperly. To some extent this can be done automatically, e.g., by introducing an interface to access sub-structures in struct mdt_thread_info, which would maintain a "busy" flag and check it on access.
> So it is rather a DIY :)
> 
> If I take an example :
> 
> mdd_thread_info.mti_xattr_buf
> 
> is there to be used when reading/changing a XATTR. If I code an helper 
> method in MDD which needs to manipulate an XATTR, this field looks 
> really interesting. But, I do not know for sure that all callers we not 
> be using it? So the only solution is that I verify each of them are not 
> using it (and their callers)? And latter, if someone add a new way to 
> call my method, he must looks for what stuff i'm using in the 
> thread_info to be sure it does not conflict with what he currently uses? 
> This seems a lot of code to check...

Well, c'est la vie. :-) I just ran a grep and found that ->mti_xattr_buf is used by 

    * mdd_create(), 

    * __mdd_lma_get(),

    * __mdd_lma_set(),

    * mdd_acl_chmod() and

    * mdd_check_acl().

Generally, foo_thread_info fields can only be used within the foo layer and one modifying it, is assumed to understand the layer.

Thank you,
Nikita. 

> 
> 
> And so, how can I chose that this field is relevant to be added to 
> thread_info instead of allocating/freeing it inside my function?
> 
> 
> Thanks for both your help
> 
> Aur?lien
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
______________________________________________________________________
This email may contain privileged or confidential information, which should only be used for the purpose for which it was sent by Xyratex. No further rights or licenses are granted to use such information. If you are not the intended recipient of this message, please notify the sender by return and delete it. You may not use, copy, disclose or rely on the information contained in it.
 
Internet email is susceptible to data corruption, interception and unauthorised amendment for which Xyratex does not accept liability. While we have taken reasonable precautions to ensure that this email is free of viruses, Xyratex does not accept liability for the presence of any computer viruses in this email, nor for any losses caused as a result of viruses.
 
Xyratex Technology Limited (03134912), Registered in England & Wales, Registered Office, Langstone Road, Havant, Hampshire, PO9 1SA.
 
The Xyratex group of companies also includes, Xyratex Ltd, registered in Bermuda, Xyratex International Inc, registered in California, Xyratex (Malaysia) Sdn Bhd registered in Malaysia, Xyratex Technology (Wuxi) Co Ltd registered in The People's Republic of China and Xyratex Japan Limited registered in Japan.
______________________________________________________________________
 
