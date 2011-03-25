From: =?ISO-8859-1?Q?Aur=E9lien_Degr=E9mont?= <aurelien.degremont@cea.fr>
Date: Fri, 25 Mar 2011 23:27:50 +0100
Subject: [Lustre-devel] The good usage of lustre *_thread_info structure
Message-ID: <4D8D16E6.8050708@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello

Doing some coding in Lustre, I'm wondering for a while was it the 
correct usage of thread_info structure like mdt_thread_info or 
mdd_thread_info.
They contain pre-allocated data or pointer to pass this between function 
call and layer without overloading the stack.
My concern is: if a function decide to use of them to store some of its 
data, how can it be sure that it was not used by an upper layer or a 
calling function?
How can I be sure it is safe to use them?

By example :

struct mdt_thread_info {
    ...
         /*
          * Object attributes.
          */
         struct md_attr             mti_attr;
     ...
}

A function in MDT layer could decide it will use this structure 
(mti_attr) for its own need, then it will call several functions that 
could have the same need. How can those functions know that they can or 
cannot re-use this structure? Same issues for pointers.

Thanks for any help

Aur?lien
