From: Vilobh Meshram <vilobh.meshram@gmail.com>
Date: Tue, 19 Oct 2010 16:28:48 -0400
Subject: [Lustre-devel] Queries regarding LDLM_ENQUEUE
In-Reply-To: <AANLkTimj53P0mnF1Wy=bN2+Sb=NnMyg8UgYKLyB7ks8=@mail.gmail.com>
References: <AANLkTimj53P0mnF1Wy=bN2+Sb=NnMyg8UgYKLyB7ks8=@mail.gmail.com>
Message-ID: <AANLkTimyq1J0gcDTeYaTNP6zbg6cRCkvFZVZ_c5izKRo@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi,

From my exploration it seems like for create/open kind of request
LDLM_ENQUEUE is the RPC through which the client talks to MDS.Please confirm
on this.

Since I could figure out that LDLM_ENQUEUE is the only RPC to interface with
MDS I am planning to send the LDLM_ENQUEUE RPC *with some additonal
buffer*from the client to the MDS so that based on some specific
condition the MDS
can fill the information in the buffer sent from the client.I have made some
modifications to the code for the LDLM_ENQUEUE RPC but I am getting kernel
panics.Can someone please help me and suggest me what is a good way to
tackle this problem.I am using Lustre 1.8.1.1 and I cannot upgrade to Lustre
2.0.

Thanks,
Vilobh
*Graduate Research Associate
Department of Computer Science
The Ohio State University Columbus Ohio*


On Mon, Oct 18, 2010 at 7:33 PM, Vilobh Meshram <vilobh.meshram@gmail.com>wrote:

> Hi,
>
> Out of the many RPC's used in Lustre seems like LDLM_ENQUEUE is the most
> frequently used RPC to communicate between the client and the MDS.I have few
> queries regarding the same :-
>
> 1) Is LDLM_ENQUEUE the only interface(RPC here) for CREATE/OPEN kind of
> request ; through which the client can interact with the MDS ?
>
> I tried couple of experiments and found out that LDLM_ENQUEUE comes into
> picture while mounting the FS as well as when we do a lookup,create or open
> a file.I was expecting the MDS_REINT RPC to get invoked in case of a
> CREATE/OPEN request via mdc_create() but it seems like Lustre invokes
> LDLM_ENQEUE even for CREATE/OPEN( by packing the intent related data).
> Please correct me if I am wrong.
>
> 2) In which cases (which system calls) does the MDS_REINT RPC will get
> invoked ?
>
>
> Thanks,
> Vilobh
> *Graduate Research Associate
> Department of Computer Science
> The Ohio State University Columbus Ohio*
>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20101019/5c80e0d6/attachment.htm>
