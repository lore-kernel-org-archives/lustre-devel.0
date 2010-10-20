From: Vilobh Meshram <vilobh.meshram@gmail.com>
Date: Tue, 19 Oct 2010 22:04:21 -0400
Subject: [Lustre-devel] Queries regarding LDLM_ENQUEUE
In-Reply-To: <D3E302FC-B752-4E9D-9E84-40F04626E8DA@oracle.com>
References: <AANLkTimj53P0mnF1Wy=bN2+Sb=NnMyg8UgYKLyB7ks8=@mail.gmail.com>
	<AANLkTimyq1J0gcDTeYaTNP6zbg6cRCkvFZVZ_c5izKRo@mail.gmail.com>
	<D3E302FC-B752-4E9D-9E84-40F04626E8DA@oracle.com>
Message-ID: <AANLkTik53-vQLA9DTj858=San9fgMB+94i8eChvHomEK@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Andreas,

Thanks for your e-mail.

We are trying to do following things.Please let me know if things are not
clear :-

Say we have 2 client C1 and C2 and a MDS .Say C1 and C2 share a file.
1) When a client C1 performs a open/create kind of request to the MDS we
want to follow the normal path which Lustre performs.
2) Now say C2 tries to open the same file which was opened by C1.
3) At the MDS end we maintain some data structure to scan and see if the
file was already opened by some Client(in this case C1 has opened this
file).
4) If MDS finds that some client(C1 here) has already opened the file then
it send the new client(C2 here) with some information about the client which
has initially opened the file.
5) Once C2 gets the information its upto C2 to take further actions.
6) By this process we can save the time spent in the locking mechanism for
C2.Basically we aim to by-pass the locking scheme of Lustre for the files
already opened by some client by maintaining some kind of data structure.

Please let us know your thoughts on the above approach.Is this a feasible
design moving ahead can we see any complications ?

So considering the problem statement I need a way for C2 to extract the
information from the data structure maintained at MDS.In order to do that ,
C2 will send a request with intent = create|open which will be a
LDLM_ENQUEUE RPC.I need to modify this RPC such that :-
1) I can enclose some additional buffer whose size is known to me .
2) When we pack the reply at the MDS side we should be able to include this
buffer in the reply message .
3) At the client side we should be able to extract the information from the
reply message about the buffer.

As of now , I need help in above three steps.

Thanks,
Vilobh
*Graduate Research Associate
Department of Computer Science
The Ohio State University Columbus Ohio*


On Tue, Oct 19, 2010 at 6:53 PM, Andreas Dilger
<andreas.dilger@oracle.com>wrote:

> On 2010-10-19, at 14:28, Vilobh Meshram wrote:
> > From my exploration it seems like for create/open kind of request
> LDLM_ENQUEUE is the RPC through which the client talks to MDS.Please confirm
> on this.
> >
> > Since I could figure out that LDLM_ENQUEUE is the only RPC to interface
> with MDS I am planning to send the LDLM_ENQUEUE RPC with some additonal
> buffer from the client to the MDS so that based on some specific condition
> the MDS can fill the information in the buffer sent from the client.
>
> This isn't correct.  LDLM_ENQUEUE is used for enqueueing locks.  It just
> happens that when Lustre wants to create a new file it enqueues a lock on
> the parent directory with the "intent" to create a new file.  The MDS
> currently always replies "you cannot have the lock for the directory, I
> created the requested file for you".  Similarly, when the client is getting
> attributes on a file, it needs a lock on that file in order to cache the
> attributes, and to save RPCs the attributes are returned with the lock.
>
> > I have made some modifications to the code for the LDLM_ENQUEUE RPC but I
> am getting kernel panics.Can someone please help me and suggest me what is a
> good way to tackle this problem.I am using Lustre 1.8.1.1 and I cannot
> upgrade to Lustre 2.0.
>
> It would REALLY be a lot easier to have this discussion with you if you
> actually told us what it is you are working on.  Not only could we focus on
> the higher-level issue that you are trying to solve (instead of possibly
> wasting a lot of time focussing in a small issue that may in fact be
> completely irrelevant), but with many ideas related to Lustre it has
> probably already been discussed at length by the Lustre developers sometime
> over the past 8 years that we've been working on it.  I suspect that the
> readership of this list could probably give you a lot of assistance with
> whatever you are working on, if you will only tell us what it actually is
> you are trying to do.
>
> > On Mon, Oct 18, 2010 at 7:33 PM, Vilobh Meshram <
> vilobh.meshram at gmail.com> wrote:
> >> Out of the many RPC's used in Lustre seems like LDLM_ENQUEUE is the most
> frequently used RPC to communicate between the client and the MDS.I have few
> queries regarding the same :-
> >>
> >> 1) Is LDLM_ENQUEUE the only interface(RPC here) for CREATE/OPEN kind of
> request ; through which the client can interact with the MDS ?
> >>
> >> I tried couple of experiments and found out that LDLM_ENQUEUE comes into
> picture while mounting the FS as well as when we do a lookup,create or open
> a file.I was expecting the MDS_REINT RPC to get invoked in case of a
> CREATE/OPEN request via mdc_create() but it seems like Lustre invokes
> LDLM_ENQEUE even for CREATE/OPEN( by packing the intent related data).
> >> Please correct me if I am wrong.
> >>
> >> 2) In which cases (which system calls) does the MDS_REINT RPC will get
> invoked ?
>
>
> Cheers, Andreas
> --
> Andreas Dilger
> Lustre Technical Lead
> Oracle Corporation Canada Inc.
>
>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20101019/2423bbd7/attachment.htm>
