From: Nikita Danilov <Nikita.Danilov@Sun.COM>
Date: Fri, 15 Feb 2008 23:40:24 +0300
Subject: [Lustre-devel] Global generic database
In-Reply-To: <47B456CC.6090400@sun.com>
References: <47B335B6.5010703@sun.com> <47B456CC.6090400@sun.com>
Message-ID: <18357.63672.838319.62694@gargle.gargle.HOWL>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Peter J Braam writes:
 > Hmm ... here are my thoughts.

Can we use our existing directory/lookup/read/write mechanism to
implement this database? That is, imagine, that clients somehow get
special fid (DB_FID), representing directory not visible through the
normal namespace (this can be implemented as a /DB directory on the MDS
local file-system, alongside the /ROOT directory). Typical use of that
would be something along the lines of

int db_value_get(const char *key, void *buf, size_t count)
{
        static struct dt_object *topdir = object_by_fid(DB_FID);

        fd = lookup(topdir, key);
        read(fd, buf, count);
        close(fd);
}

db_value_get("filesets.FOO.policy", buf, BUFSIZE);
db_value_get("pools.BAR.width", &pool_width, sizeof pool_width);

etc.

Main advantage of this approach is of course that all code is already
here, moreover...

 > 
 > 1. The word scalable is missing below.

fixed through the standards means: CMD, placement policies, split
directories, pdirops-locking,

 > 
 > 2. Any database that relates to file system policies and file system 
 > objects (HSM?) should be a separate mechanism coupled to the file 
 > system, so that you can pick up the server disks and the policies.

achieved automatically (if I understand the issue correctly),

 > 
 > 3. I think all updates to the database should be made on the server, and 
 > the use cases should be restricted (e.g. this is for relatively small 
 > databases).
 > 
 > 4. Imho pools belong in the configuration log. 
 > 
 > 5. Fileset attributes belong with the file system (see 2) - either these 
 > are implemented as special directory files and/or EA's (does the design 
 > specify the purpose and items that need to be stored in databases?).
 > 

[...]

 > > Needs to be:
 > > 1. Fast. We need to cache database entries locally, which also means 

hopefully fast. :-) Caching is already here,

 > > having them under locks.
 > >     a. local caching

already here,

 > >     b. locks

already here,

 > > 2. Generic.  Store any kind of data, not limited to 8k page boundaries, etc.

already here,

 > > 3. Transactional.  Power loss doesn't lead to inconsistent state.

already here,

 > > 4. Recoverable. Client changes are replayed if need be.

already here,

 > > 5. Remotely accessible, from a client or other servers.

already here.

Plus, we can allow clients to mount DB_FID as a separate file system, so
that usual tools can be used to maintain the database.

Nikita.
