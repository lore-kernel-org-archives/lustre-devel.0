From: Vilobh Meshram <vilobh.meshram@gmail.com>
Date: Mon, 18 Oct 2010 19:33:36 -0400
Subject: [Lustre-devel] Queries regarding LDLM_ENQUEUE
Message-ID: <AANLkTimj53P0mnF1Wy=bN2+Sb=NnMyg8UgYKLyB7ks8=@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi,

Out of the many RPC's used in Lustre seems like LDLM_ENQUEUE is the most
frequently used RPC to communicate between the client and the MDS.I have few
queries regarding the same :-

1) Is LDLM_ENQUEUE the only interface(RPC here) for CREATE/OPEN kind of
request ; through which the client can interact with the MDS ?

I tried couple of experiments and found out that LDLM_ENQUEUE comes into
picture while mounting the FS as well as when we do a lookup,create or open
a file.I was expecting the MDS_REINT RPC to get invoked in case of a
CREATE/OPEN request via mdc_create() but it seems like Lustre invokes
LDLM_ENQEUE even for CREATE/OPEN( by packing the intent related data).
Please correct me if I am wrong.

2) In which cases (which system calls) does the MDS_REINT RPC will get
invoked ?


Thanks,
Vilobh
*Graduate Research Associate
Department of Computer Science
The Ohio State University Columbus Ohio*
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20101018/9f652e32/attachment.htm>
