From: Andreas Dilger <adilger@whamcloud.com>
Date: Wed, 27 Feb 2019 06:37:49 +0000
Subject: [lustre-devel] [PATCH 29/37] lustre: handles: discard h_owner
 in favour of h_ops
In-Reply-To: <155053494646.24125.10155576042684274174.stgit@noble.brown>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
 <155053494646.24125.10155576042684274174.stgit@noble.brown>
Message-ID: <FC69F452-EB61-4535-A2DC-5B2052224885@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Feb 18, 2019, at 17:09, NeilBrown <neilb@suse.com> wrote:
> 
> lustre_handles  assigned a  64bit  unique identifier  (a 'cookie')  to
> objects of  various types and  stored them  in a hash  table, allowing
> them to be accessed by the cookie.
> 
> The is a facility for type checking by recording an 'owner' for each
> object, and checking the owner on lookup.  Unfortunately this is not
> used - owner is always zero.
> 
> Eahc object also contains an h_ops pointer which can be used to
> reliably identify an owner.
> 
> So discard h_owner, pass and 'ops' pointer to class_handle2object(),
> and only return objects for which the h_ops matches.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>

The h_owner is not used in the client code, but it is still used in the
server code to ensure that only clients which have already opened a file
handle can use the open file handle cookie to re-open the file.  The
h_owner in this case is an MDS-local pointer to the client export data,
so just using the h_ops pointer (which is generic to the class of users,
not the specific user) would not provide this functionality.

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud
