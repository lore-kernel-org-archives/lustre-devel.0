From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Mon, 23 Apr 2018 22:12:30 +0530
Subject: [lustre-devel] [PATCH] staging: lustre: Change return type to
 vm_fault_t
In-Reply-To: <20180422032052.GH14610@bombadil.infradead.org>
References: <20180421221723.GA3054@jordon-HP-15-Notebook-PC>
 <20180422032052.GH14610@bombadil.infradead.org>
Message-ID: <CAFqt6zaomQW5K_OeYUJjbbv2p8=fMRCuBJVvghyskgMVdPQDdQ@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Apr 22, 2018 at 8:50 AM, Matthew Wilcox <willy@infradead.org> wrote:
> On Sun, Apr 22, 2018 at 03:47:24AM +0530, Souptick Joarder wrote:
>> @@ -261,7 +261,7 @@ static inline int to_fault_error(int result)
>>   * \retval VM_FAULT_ERROR on general error
>>   * \retval NOPAGE_OOM not have memory for allocate new page
>>   */
>> -static int ll_fault0(struct vm_area_struct *vma, struct vm_fault *vmf)
>> +static vm_fault_t ll_fault0(struct vm_area_struct *vma, struct vm_fault *vmf)
>>  {
>>       struct lu_env      *env;
>>       struct cl_io        *io;
>
> Did you compile-test this with the sparse changes?  Because I can see
> a problem here:

Yes, compile-tested. Sparse didn't throw any warning/error.

>
>         env = cl_env_get(&refcheck);
>         if (IS_ERR(env))
>                 return PTR_ERR(env);
>
>> @@ -269,7 +269,7 @@ static int ll_fault0(struct vm_area_struct *vma, struct vm_fault *vmf)
>>       struct page          *vmpage;
>>       unsigned long       ra_flags;
>>       int                   result = 0;
>> -     int                   fault_ret = 0;
>> +     vm_fault_t              fault_ret = 0;
>
> What odd indentation ...

Sorry, will correct it.
>
