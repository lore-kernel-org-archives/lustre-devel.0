From: Nikita Danilov <Nikita.Danilov@Sun.COM>
Date: Sat, 02 Feb 2008 14:22:21 +0300
Subject: [Lustre-devel] Reducing amount of glimpses
In-Reply-To: <A1C83110-58BF-43A2-88F3-68C6C53BFB6C@sun.com>
References: <A1C83110-58BF-43A2-88F3-68C6C53BFB6C@sun.com>
Message-ID: <18340.21101.635645.378808@gargle.gargle.HOWL>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Oleg Drokin writes:
 > Hello!
 > 
 >     Doing some large scale testing at ORNL, interesting pattern came up.
 >     Suppose we are doing large-scale IOR testing on a shared file.
 >     Some unlucky client does its writing at highest offset (or, at the  
 > beginning,
 >     was unlucky enough to grab whole-object PW lock).
 >     As other clients do their writes, they would do glimpses first to  
 > find out file
 >     size. Now those glimpses turn into thousands of glimpse requests  
 > to that poor
 >     client. And many of them actually coming in parallel.

I think there is a way to further reduce the number of glimpses sent in
the read/write paths. In a situation when client is doing read and the
region being read ends in a certain stripe, it's often enough to send a
glimpse request only to the OST where this stripe is located. Indeed, if
stripe is not a hole, then size of this stripe alone is sufficient to
determine whether we are in a short read situation or not. Of course if
stripe happens to end in a hole, client needs to send more glimpses, but
in the most common case of non-sparse file, 1 RPC seems to be enough.

 > 
 > Bye,
 >      Oleg

Nikita.
