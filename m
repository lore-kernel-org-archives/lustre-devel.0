From: Tom.Wang <Tom.Wang@Sun.COM>
Date: Mon, 21 Jul 2008 14:14:14 -0400
Subject: [Lustre-devel] Lustre IO discussion between CERN and Lustre
Message-ID: <4884D1F6.7050109@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello,

There is an interesting discussion between CERN and Lustre group about
running CERN application on lustre recently. You might be interested

The application description from CERN,

"Our ROOT framework supports an object persistency system that, in a
very first approximation) organizes a data set (say one file) like
an RDBMS table, but being column-oriented instead of row-oriented.
Our main data structure (Tree) may have several hundred, up to a
few thousand branches (columns). The Tree with its N branches is
filled from the objects coming from our collisions (called events)
and we have zillions of collisions. Each branch is created with a
buffer size around 32 KBytes. When the buffer is full, it is
compressed (compression factors are typycally between 2 and 5) and
written to the file. Files may be between 100 Mbytes and 10 GBytes
and we have  millions of files. The compression factor is pretty
high because our branches contain similar data types for which the
compression is typycally 30% better than compressing buffers with
non homogeneous types. So a branch may have several thousand buffers
in the file.

When reading the Tree, in general only a small subset of the N
branches is used. In the data structure for our branches,part of
the tree header) we keep the file offsets and number of bytes
corresponding to each compressed buffer. Our query mechanism (think
to an SQL-like query) can pass a vector of pairs (offsets,nbytes)
to the I/O sub-system."

Interests from CERN group to Lustre

1)Implement a list vector read/write API(readx/writex) for this
  application.

2)For readx, it could read-ahead buffers from vectors of the pairs
  provided by users.

"when reading .... Our query mechanism (think
to an SQL-like query) can pass a vector of pairs (offsets,nbytes)
to the I/O sub-system. We simply tell the I/O to return up to a maximum (say
10 Mbytes) of buffers (in general several hundred, a few thousand
buffers). We expect the I/O to be clever enough to use the vector
of pairs info to organize its internal read-ahead (via threads)
such that our next request of 10 Mbytes can be satisfied
immediately.  "

Suggestions from Lustre group.

1)Current lustre read_ahead mechanisms will only be triggered by
  contiguous or stride IO mode. But Lustre could update the read-ahead
  mechanisms to do RA according to the vector pairs.

2)For a single client, for each read request, current lustre read mechanism
  is basicly serialized(for each page), and it should be improved to 
fire off
  read request to OSTs parallel by implementing an async read loop on
  client(llite).

3)This kind of seek-heavy application model(read-size is about 30k, but 
might
  discontiguous on file offset)might hit the bottom of server
  disk IO, so a OSS read-cache might needed for this kind of IO pattern. 
Given
  that some OSS servers might concern about RAM, only special files will be
  enable for this read-cache features.

Any other ideas?

Thanks
WangDi

-- 
Regards,
Tom Wangdi    
--
Sun Lustre Group
System Software Engineer 
http://www.sun.com
