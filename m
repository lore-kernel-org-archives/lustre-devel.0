From: Peter Braam <Peter.Braam@Sun.COM>
Date: Sun, 01 Jun 2008 10:26:41 +0800
Subject: [Lustre-devel] Moving forward on Quotas
In-Reply-To: <18493.29199.765234.755534@gargle.gargle.HOWL>
Message-ID: <C46829E1.5610%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Jeff - 

could you get in touch with Nikita and Ricardo and assist them with a draft
of quota design for the DMU.  Nikita has some interesting API proposals, but
there are some pretty deep ZFS issues involved where help would be welcome,
as far as I can see.

Just as a heads up, quota in systems like Lustre is quite a difficult issue,
as many servers contribute to quota usage and this needs "acquire", and
"release" of quota in reasonable chunks to avoid the server server protocol
getting too chatty.

Thank you for your help!

Peter


On 5/28/08 10:54 PM, "Nikita Danilov" <Nikita.Danilov@Sun.COM> wrote:

> Ricardo M. Correia writes:
>> On Ter, 2008-05-27 at 07:28 +0800, Peter Braam wrote:
>> 
>>>> Going aside, if I were designing quota from the scratch right now, I
>>>> would implement it completely inside of Lustre. All that is needed for
>>>> such an implementation is a set of call-backs that local file-system
>>>> invokes when it allocates/frees blocks (or inodes) for a given
>>>> object. Lustre would use these call-backs to transactionally update
>>>> local quota in its own format. That would save us a lot of hassle we
>>>> have dealing with the changing kernel quota interfaces, uid re-mappings,
>>>> and subtle differences between quota implementations on a different file
>>>> systems.
>>> 
>>> ======> IMPORTANT: get in touch with Jeff Bonwick now, let's get quota
>>> implemented in this way in DMU then.
>> 
>> 
>> I think this was proposed by Alex before, but AFAIU the conclusion is
>> that this was not possible to do with ZFS (or at least, not easy to do).
>> 
>> The problem is that ZFS uses delayed allocations, i.e., allocations
>> occur long after a transaction group has been closed, and therefore we
>> can't transactionally keep track of allocated space because by the time
>> the callbacks were called we are not allowed to write to the transaction
>> group anymore, since another 2 txgs could have been opened already.
> 
> But that problem has to be solved anyway to implement per-user quotas
> for ZFS, correct?
> 
> One possible solution I see is to use something like ZIL to log
> operations in the context of current transaction group. This log can be
> replayed during mount to update quota file.
> 
>> 
>> Since this couldn't be done transactionally, if the node crashes, there
>> would be no way of knowing how many blocks had been allocated on the
>> latest (actually, the latest 2) committed transaction groups..
>> 
>> Regards,
>> Ricardo
> 
> Nikita.
