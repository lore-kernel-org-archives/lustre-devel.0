From: Andreas Dilger <andreas.dilger@oracle.com>
Date: Tue, 19 Oct 2010 16:53:18 -0600
Subject: [Lustre-devel] Queries regarding LDLM_ENQUEUE
In-Reply-To: <AANLkTimyq1J0gcDTeYaTNP6zbg6cRCkvFZVZ_c5izKRo@mail.gmail.com>
References: <AANLkTimj53P0mnF1Wy=bN2+Sb=NnMyg8UgYKLyB7ks8=@mail.gmail.com>
	<AANLkTimyq1J0gcDTeYaTNP6zbg6cRCkvFZVZ_c5izKRo@mail.gmail.com>
Message-ID: <D3E302FC-B752-4E9D-9E84-40F04626E8DA@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2010-10-19, at 14:28, Vilobh Meshram wrote:
> From my exploration it seems like for create/open kind of request LDLM_ENQUEUE is the RPC through which the client talks to MDS.Please confirm on this.
> 
> Since I could figure out that LDLM_ENQUEUE is the only RPC to interface with MDS I am planning to send the LDLM_ENQUEUE RPC with some additonal buffer from the client to the MDS so that based on some specific condition the MDS can fill the information in the buffer sent from the client.

This isn't correct.  LDLM_ENQUEUE is used for enqueueing locks.  It just happens that when Lustre wants to create a new file it enqueues a lock on the parent directory with the "intent" to create a new file.  The MDS currently always replies "you cannot have the lock for the directory, I created the requested file for you".  Similarly, when the client is getting attributes on a file, it needs a lock on that file in order to cache the attributes, and to save RPCs the attributes are returned with the lock.

> I have made some modifications to the code for the LDLM_ENQUEUE RPC but I am getting kernel panics.Can someone please help me and suggest me what is a good way to tackle this problem.I am using Lustre 1.8.1.1 and I cannot upgrade to Lustre 2.0.

It would REALLY be a lot easier to have this discussion with you if you actually told us what it is you are working on.  Not only could we focus on the higher-level issue that you are trying to solve (instead of possibly wasting a lot of time focussing in a small issue that may in fact be completely irrelevant), but with many ideas related to Lustre it has probably already been discussed at length by the Lustre developers sometime over the past 8 years that we've been working on it.  I suspect that the readership of this list could probably give you a lot of assistance with whatever you are working on, if you will only tell us what it actually is you are trying to do.

> On Mon, Oct 18, 2010 at 7:33 PM, Vilobh Meshram <vilobh.meshram@gmail.com> wrote:
>> Out of the many RPC's used in Lustre seems like LDLM_ENQUEUE is the most frequently used RPC to communicate between the client and the MDS.I have few queries regarding the same :-
>> 
>> 1) Is LDLM_ENQUEUE the only interface(RPC here) for CREATE/OPEN kind of request ; through which the client can interact with the MDS ? 
>> 
>> I tried couple of experiments and found out that LDLM_ENQUEUE comes into picture while mounting the FS as well as when we do a lookup,create or open a file.I was expecting the MDS_REINT RPC to get invoked in case of a CREATE/OPEN request via mdc_create() but it seems like Lustre invokes LDLM_ENQEUE even for CREATE/OPEN( by packing the intent related data).
>> Please correct me if I am wrong.
>> 
>> 2) In which cases (which system calls) does the MDS_REINT RPC will get invoked ? 


Cheers, Andreas
--
Andreas Dilger
Lustre Technical Lead
Oracle Corporation Canada Inc.
