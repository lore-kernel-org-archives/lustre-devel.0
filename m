From: Yong Fan <Yong.Fan@Sun.COM>
Date: Tue, 10 Jun 2008 21:54:03 +0800
Subject: [Lustre-devel] Moving forward on Quotas
In-Reply-To: <C46E87FA.589E%peter.braam@sun.com>
References: <C46E87FA.589E%peter.braam@sun.com>
Message-ID: <484E877B.50500@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Peter Braam ??:
>
> On 6/6/08 1:33 AM, "Johann Lombardi" <johann@sun.com> wrote:
>
>   
>> On Thu, Jun 05, 2008 at 06:45:36AM -0700, Peter Braam wrote:
>>     
>>> Well, this protocol hasn't been published yet; why not include the server
>>> side uid / gid then?
>>>       
>> I understood from Fanyong that according to the remote client design
>> requirements, we should not allow the remote client to access the server-side
>> uid/gid mapping.
>>     
>
> You have two choices: break that rule OR let the MDS server do the ownership
> changes.  It's not complicated, just make a choice.
>   
1) MDS changes file owner for objects on OSS when create.
It introduces one additional RPC between MDS and OSS
for each objects, which causes the per-create meaningless.
Maybe we can not accept the creation performance undre
such case.
An improvement for that is that we can initialize all
the pre-create objects on OSS with the same uid/gid as
the current created file. And the succedent creations
check the per-created object's uid/gid, if they match
the owner's uid/gid, then the additional setattr to OSS
is unnecessary, otherwise, chown to OSS will be sent.
The best case is equal to the current implementation;
the worst case is equal to no such improvement.
Under creation performance sensitivity case, maybe HPC
or some benchmark test. There are few uid/gid context
switch. So I think such improvement can match most
creation performance requirement.
2) Pack file owner into OSS capability when write to OSS.
According to our UID mapping rules, we do not want the
client (especially the untrusted client, maybe remote
client) to know which the server-side uid/gid are mapped.
For that, dynamic UID mapping are used, and some complex
remote acl operations are implemented.
So if file real owner (server-side uid/gid) need to be
packed in OSS capability back to client, bad better to
encrypt them to match our UID mapping rules. Otherwise,
most of our effort for that before are broken. On the
other hand, MDS/OSS capabilities use HMAC-SHA1 to prevent
from being modified or fabricated. Signing MAC is somewhat
time-consuming, and uid/gid encryption are similar, so the
performance will become worse. To implement server-side
uid/gid encryption and decryption, need to design some
key-update mechanism also.
So I do not think it is a good choice.
3) Establish UID mapping on OSS also, just like MDS does.
It has the same principle as done on MDS which needs
lower layer GSS support. Many codes can be shared
between MDS and OSS for UID mapping. It is the most
complete solution, little affect on creation performance
and UID mapping rules. The shortcoming is much changes
on OSS, how much GSS effort for that is not well estimated
yet.
>   
>>> But more seriously, how is this encoded in such a way that the OST can trust
>>> the information - it must be in the capability too?
>>>       
>> hmm, I don't see any capability associated with this.
>>     
>
> We had better find it, otherwise there is a security hole.
>
>   
Root user's super permission should be considered for OSS
capability. On client-side, the opened file descriptor can
be shared by different threads, and the different threads
maybe have different "uid". Consider the following case:
Root user writes a file through other normal user (Tom)
opened file descriptor. The root user can breaks through
Tom's quota limitation, he should tell OSS that he is a
root user, but how can the OSS believe him? Such information
should be contained in the OSS capability.
(Note: on lustre 1.6, llite set "OBD_BRW_NOQUOTA" directly
for that, which can be fabricated by baleful client)

Best Regards!
--
Fan Yong
>   
>> Johann
>> _______________________________________________
>> Lustre-devel mailing list
>> Lustre-devel at lists.lustre.org
>> http://lists.lustre.org/mailman/listinfo/lustre-devel
>>     
>
>
>   
