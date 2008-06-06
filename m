From: Peter Braam <Peter.Braam@Sun.COM>
Date: Thu, 05 Jun 2008 20:36:34 -0700
Subject: [Lustre-devel] Replication/server logs
In-Reply-To: <48481A61.8070105@sun.com>
Message-ID: <C46DFED2.587E%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Added Lustre devel

Jeff will schedule regular calls with us, just spoke with him yesterday.


On 6/5/08 9:54 AM, "Nathaniel Rutman" <Nathan.Rutman@Sun.COM> wrote:

> So far there are three problems with ZFS changelogs that I have come across:
> 
> 1. potentially slow path lookup.  There is an existing function
> zfs_obj_to_path that does the job by searching for the object number in
> the parent directory, so O(dir_entries) for each ancestor.  Supposedly
> Jeff Bonwick has some ideas on this besides our two old ideas (obj,name
> database and storing name in an EA), but I have heard nothing from him
> and not much from the rest of the ZFS team.  Mitigation: we could just
> ignore this problem for now and consider it an optimization.

Yes, but the optimization is a must have.


> 
> 2. hardlinks - a single parent object is stored with each object (the
> last hardlink).  But if that parent is unlinked, then an object may be
> orphaned with no valid parent (until a directory lookup of one of the
> other links.)  So we would (eventually) need a solution dealing with
> multiple hardlinks; this should be addressed in the solution for #1
> above.  Mitigation: we may choose not to consider this a critical use
> case in the initial implementation.

Indeed, ignore for now, but solve in #1.
> 
> 3. directory content deltas to file names - the only change information
> we have is modified blocks, not a list of modified files.  Files that
> have been modified are directly/easily identified by object number, but
> renames for instance can only be detected by a careful comparison
> between an old raw block from a directory and the new version of that
> block.  And the directory structure can be quite complex (different
> versions are used depending on file name length, for instance).  Really
> we should use the native directory parsing tools, but they require the
> user to start reading from the beginning and the current position in the
> directory is opaque, so there's no easy way to find just the objects
> associated with the changed directory block.  So in the worst case, for
> renames (and maybe creates/unlinks), we would scan and compare the
> entire (top level) contents of the old and new directories.

We need new tools.  Zapdiff should become a general function is what Bill
Moore said a few weeks ago.
