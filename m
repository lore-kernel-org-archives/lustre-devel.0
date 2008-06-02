From: Nikita Danilov <Nikita.Danilov@Sun.COM>
Date: Mon, 02 Jun 2008 15:11:36 +0400
Subject: [Lustre-devel] Re-direction inodes
In-Reply-To: <C4696703.566A%peter.braam@sun.com>
References: <C4696703.566A%peter.braam@sun.com>
Message-ID: <18499.54632.983384.565997@gargle.gargle.HOWL>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Peter Braam writes:
 > Hi Nikita -
 > 
 > I have a need in doing an architecture for a customer of a Lustre client
 > feature to have different data/page caches associated with an inode,
 > depending on the user that accesses it.    So when a file is read, user A
 > will read different data from user B (assume the same for writes, but I
 > think this is a read-only feature).
 > 
 > I remember that in the Coda file system we could easily re-direct I/O to
 > another inode using almost standard features in the VFS/page caches.  Is
 > this still the case?  Would this work for the purpose I describe above?

I am not sure how this can be done with the VFS mechanisms. Alex pointed
out that some kind of stacked file system similar to smfs can be used
for this purpose.

 > 
 > Thanks.
 > 
 > Peter

Nikita.
