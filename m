From: Oleg Drokin <Oleg.Drokin@Sun.COM>
Date: Wed, 29 Jul 2009 15:05:41 -0400
Subject: [Lustre-devel] SMP Scalability, MDS, reducing cpu pingpong
In-Reply-To: <1248893731.4563.13.camel@localhost>
References: <7580C3C1-7634-47C8-827B-C93157C1301A@Sun.COM>
	<002001ca1062$7b526fc0$71f74f40$@com>
	<31A2D6F1-C723-4EB5-8515-D155FE923C9A@Sun.COM>
	<1248893731.4563.13.camel@localhost>
Message-ID: <89C349D2-F60A-44C1-9678-076DC8AD0A5A@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Jul 29, 2009, at 2:55 PM, Ricardo M. Correia wrote:

> On Qua, 2009-07-29 at 12:01 -0400, Oleg Drokin wrote:
>> Yes. If clients are not contending, we have same benefits, but
>> this never happens in the real world.
>> Creates in a same dir is a contention point on the dir and there is
>> no point in scheduling all clients on different cpus and let them
>> serialize, where we can free those cpus for some other set of clients
>> doing something else.
> Will this still be true with the DMU?

To some degree.
Even without DMU HEAD has pdirops enabled which reduces the locking  
unit to
certain subset of hash values only.
Keep in mind that aside from the dir content locking there is another  
point of
serialization which is to lock entire directory inode to update times,  
size
and possibly link count (of course normally this is quite small section
that is lost in the noise of search in the directory, but when you  
have a lot of
CPUs, bouncing these pages and locks around cpu caches might raise level
of overhead significantly).

> I don't know which locks are involved at the Lustre level, but the DMU
> itself does leaf-level locking of ZAP structures (used for  
> directories).

Possibly more than one, since in order to ensure you are not inserting a
duplicate entry (with big enough dir) you need to lock all blocks that  
could
contain entries in a given hash range/whatever is the way ZIL(?)  
orders entries with

Bye,
     Oleg
