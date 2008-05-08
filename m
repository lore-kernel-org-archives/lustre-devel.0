From: Peter Braam <Peter.Braam@Sun.COM>
Date: Thu, 08 May 2008 08:57:04 -0600
Subject: [Lustre-devel] Replication
In-Reply-To: <18467.4769.687089.205938@gargle.gargle.HOWL>
Message-ID: <C44870E0.410B%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org




On 5/8/08 8:48 AM, "Nikita Danilov" <Nikita.Danilov@Sun.COM> wrote:

> Peter Braam writes:
>> On 5/6/08 11:43 AM, "Nathaniel Rutman" <Nathan.Rutman@Sun.COM> wrote:
> 
> [...]
> 
>>> 
>>> For 2 and 3, we could store the directory name for each directory in an
>>> EA, and all the fids for all the parents in some other manner.
>>> But it seems to make more sense at this point to put all this
>>> information (fid, name, parent list) in a database file stored on the
>>> MDT.  Then we just look through this database to generate our full path
> 
> One advantage EA has over global data-base is that the former is more
> resilient against file system corruption. This becomes more important if
> we ever plan to use (parent-fid, name) information for things like fsck.
> 
>>> information; no need to lookup info in the file objects or EAs.
>>> Generating this database should be no more time consuming than writing
>>> the changelogs themselves, assuming a reasonable database structure like
>>> IAM.
> 
> On a lower level note, I think that changelogs and parent-database are
> better to be implemented as a new layer separate from mdd:
> 
>     - mdd code is already complicated enough,
> 
>     - separate layer can be inserted into stack optionally, avoiding
>     run-time cost if change-logs are not needed (currently there is no
>     way to insert a layer after initial configuration completes though).

Yes, find a good place.

Just remember that things like pNFS integrated with the Lustre servers also
need to replicate.  In fact having this log purely at the DMU / ZFS level
would be a valuable feature - there are no good replication solutions even
for laptops today!

Peter


> 
>>> 
>> 
>> Yes I agree with all of this.
>> 
>> Peter
>> 
> 
> Nikita.
