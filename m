From: Fan Yong <yong.fan@whamcloud.com>
Date: Tue, 19 Oct 2010 23:46:37 +0800
Subject: [Lustre-devel] Queries regarding LDLM_ENQUEUE
In-Reply-To: <AANLkTimj53P0mnF1Wy=bN2+Sb=NnMyg8UgYKLyB7ks8=@mail.gmail.com>
References: <AANLkTimj53P0mnF1Wy=bN2+Sb=NnMyg8UgYKLyB7ks8=@mail.gmail.com>
Message-ID: <4CBDBD5D.9060600@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

  On 10/19/10 7:33 AM, Vilobh Meshram wrote:
> Hi,
>
> Out of the many RPC's used in Lustre seems like LDLM_ENQUEUE is the 
> most frequently used RPC to communicate between the client and the 
> MDS.I have few queries regarding the same :-
>
> 1) Is LDLM_ENQUEUE the only interface(RPC here) for CREATE/OPEN kind 
> of request ; through which the client can interact with the MDS ?
>
> I tried couple of experiments and found out that LDLM_ENQUEUE comes 
> into picture while mounting the FS as well as when we do a 
> lookup,create or open a file.I was expecting the MDS_REINT RPC to get 
> invoked in case of a CREATE/OPEN request via mdc_create() but it seems 
> like Lustre invokes LDLM_ENQEUE even for CREATE/OPEN( by packing the 
> intent related data).
> Please correct me if I am wrong.
For OPEN_CREATE case, it is through LDLM_ENQUEUE interface to 
communicate with MDS.
>
> 2) In which cases (which system calls) does the MDS_REINT RPC will get 
> invoked ?
You can try mkdir/symlink/mknode to trigger MDS_REINT.


Cheers,
--
Nasf
>
>
> Thanks,
> Vilobh
> /Graduate Research Associate
> Department of Computer Science
> The Ohio State University Columbus Ohio/
>
>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20101019/92866d97/attachment.htm>
