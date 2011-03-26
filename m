From: Nikita Danilov <Nikita_Danilov@xyratex.com>
Date: Sat, 26 Mar 2011 00:52:49 -0700
Subject: [Lustre-devel] The good usage of lustre *_thread_info structure
In-Reply-To: <4D8D16E6.8050708@cea.fr>
References: <4D8D16E6.8050708@cea.fr>
Message-ID: <73AED5C780AE05478241DB067651A92102000E2A@XYUS-EX22.xyus.xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mar 26, 2011, at 01:27 , Aur?lien Degr?mont wrote:

> Hello

Hello Aur?lien,

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

the answer is: by trusting everybody to follow the convention. In the meta-data stack each "method" takes a pointer to struct lu_env is a parameter. This environment contains two "contexts" (struct lu_ctx): lu_env::le_ctx and lu_env::le_ses.

By convention, lu_env::le_ctx should be used only as a substitute for an automatic variables, that is, it is used to conserve a space on the stack (which is a rather limited resource in kernel space) and should never me used to pass information between functions. lu_env::le_ses is a context embedded into a request, which can  be used to store some request-global information, like credentials.

For the call chains within a layer it is up to the programmer to ascertain that the same element of lu_env::le_ctx is not re-used improperly. To some extent this can be done automatically, e.g., by introducing an interface to access sub-structures in struct mdt_thread_info, which would maintain a "busy" flag and check it on access. 

Hope this helps,
Nikita.

> 
> By example :
> 
> struct mdt_thread_info {
>    ...
>         /*
>          * Object attributes.
>          */
>         struct md_attr             mti_attr;
>     ...
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
______________________________________________________________________
This email may contain privileged or confidential information, which should only be used for the purpose for which it was sent by Xyratex. No further rights or licenses are granted to use such information. If you are not the intended recipient of this message, please notify the sender by return and delete it. You may not use, copy, disclose or rely on the information contained in it.
 
Internet email is susceptible to data corruption, interception and unauthorised amendment for which Xyratex does not accept liability. While we have taken reasonable precautions to ensure that this email is free of viruses, Xyratex does not accept liability for the presence of any computer viruses in this email, nor for any losses caused as a result of viruses.
 
Xyratex Technology Limited (03134912), Registered in England & Wales, Registered Office, Langstone Road, Havant, Hampshire, PO9 1SA.
 
The Xyratex group of companies also includes, Xyratex Ltd, registered in Bermuda, Xyratex International Inc, registered in California, Xyratex (Malaysia) Sdn Bhd registered in Malaysia, Xyratex Technology (Wuxi) Co Ltd registered in The People's Republic of China and Xyratex Japan Limited registered in Japan.
______________________________________________________________________
 
