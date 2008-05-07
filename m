From: Peter Braam <Peter.Braam@Sun.COM>
Date: Tue, 06 May 2008 23:57:33 -0600
Subject: [Lustre-devel] Replication
In-Reply-To: <482098C9.4020403@sun.com>
Message-ID: <C446A0ED.405C%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 5/6/08 11:43 AM, "Nathaniel Rutman" <Nathan.Rutman@Sun.COM> wrote:

> Peter Braam wrote:
>> Hi Nathan -
>> 
>> I talked through the design with Nikita.  After he had understood our
>> constraints and I had understood his issues it all narrowed down to
>> one important improvement that Nikita suggests:  we must get a fast
>> way to compute the pathname of a FID.  The scanning and searching I
>> suggested without an index is not tenable.
>> 
>> We had a couple of suggestions, such as storing parent fid and a name
>> in the EA, or storing similar information in a large directory file.
>> 
>> Can you connect with Nikita and do this?
> 
> We talked yesterday afternoon.
> Nikita has three concerns:
> 
> 1. Global lock on namespace during pathname reconstruction.
> I think we can eliminate this the following way:
> a. lookup full path from fid, parent fid (remember the list of fids for
> the entire path also)
> b. lookup last transno
> c. verify traversing down the full path name results in the same branch
> and leaf fids all the way back down
>  i. if they don't match, repeat from a
>  ii. if they do match, we can backtrack starting from the transno in b
> to regenerate the original name
> 
> 2. Directory name lookup given the parent fid - this may be inefficient
> if we have to read the parent directory in order to get the name (parent
> object is not likely to be cached at lookup time).
> 
> 3. Someone deletes one of the parents of a hardlinked file.  If we only
> store one parent, there's no way to regenerate a pathname if that parent
> is the one that gets removed.
> 
> For 2 and 3, we could store the directory name for each directory in an
> EA, and all the fids for all the parents in some other manner.
> But it seems to make more sense at this point to put all this
> information (fid, name, parent list) in a database file stored on the
> MDT.  Then we just look through this database to generate our full path
> information; no need to lookup info in the file objects or EAs.
> Generating this database should be no more time consuming than writing
> the changelogs themselves, assuming a reasonable database structure like
> IAM.
> 

Yes I agree with all of this.

Peter
