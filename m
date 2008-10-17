From: Peter Braam <Peter.Braam@Sun.COM>
Date: Fri, 17 Oct 2008 07:54:36 -0600
Subject: [Lustre-devel] "Simple" HSM straw man
In-Reply-To: <48F85F43.2050007@cea.fr>
Message-ID: <C51DF53C.6247%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org




On 10/17/08 3:47 AM, "Aurelien Degremont" <aurelien.degremont@cea.fr> wrote:

> Eric Barton a ?crit :
>> Partially purged files is a requirement to allow graphical file browsers
>> to retrieve icons from within the file.  It's OK to miss this out in the
>> first version, but it has to be there for the full product.
> 
> Think also of command like
> 
> $ file foo*
> 
>>>> Is it interesting to have a file that is outdated and possibly
>>>> uncoherent?

99.99% of (probably more 9's) backup systems do work this way, with
relatively little harm.

Also remember that many files are append only - for those it might be fine.

Philosophically it is a disaster of course.  I would offer archiving of
files that are active, and in due course use snapshots.

Peter


>>> It is probably useful in some cases -- simulation checkpoints maybe.
>> 
>> A corrupt simulation checkpoint is useless.  We _must_ provide a way to
>> ensure the HSM copy of a file is a known good snapshot.  We don't
> necessarily
>> have to abort the copyout if there is an update that could mean the
>> HSM copy would be corrupt since we can always just copy it out again,
>> but it doesn't seem hugely complicated to notify the backend, if not
>> the agent and let it decide.
> 
> Indeed, this is important
> 
>>> I don't think we want to block the write just because the HSM copy
> isn't
>>> done yet.  If the data is changing, then the policy engine shouldn't
>>> have started a copyout process in the first place.
>> 
>> Indeed.
> 
> You were speaking of a FS with only one big file and so we need to have
> a way to be sure it will be copied at least once, even if people are
> writting on it.
> In this case, with a classical policy engine, this file will never be
> copied out because data is constantly changing.
> 
> 
