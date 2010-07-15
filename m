From: Ken Hornstein <kenh@cmf.nrl.navy.mil>
Date: Thu, 15 Jul 2010 14:43:29 -0400
Subject: [Lustre-devel] Size-On-Metadata suboptimality
Message-ID: <201007151843.o6FIhUZV028069@hedwig.cmf.nrl.navy.mil>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

So, still working on attribute caching ... and I guess there's some things
I've discovered, and some things I don't understand.

- The actual size-on-metadata support is kinda hard to get going.  You have
  to set the right mgs parameter, _and_ you have to make sure the metadata
  server is started with no clients are running.  Even if you have it running
  and have clients connected that are using SOM, if you restart the metadata
  server SOM will be disabled when you restart the metadata server.  I'm
  assuming that's a bug.

- Because of the previous issue, it's very likely that your files will have
  any SOM information.  However, from what I can tell if your client does need
  to make any attribute changes to the file SOM data will be stored for those
  files, which is helpful (to verify that the SOM data exists, I figured out
  where it is stored in the extended attributes).  Although that only happens
  when you do something like touch the file, unfortunately (I guess "chown"
  might work as well, but I haven't checked that yet).

- Even if you have SOM information for a file, _and_ your server has it
  turned on, _and_ you indicate in your connection that you support SOM,
  the metadata server is EXTREMELY stingy about when it will hand that out.
  As far as I can tell, this only happens when you do a metadata request
  under an MDS_INODELOCK_UPDATE lock.

That last bit is causing me extreme amounts of discomfort, and it's also
confusing.  How come the MDS server will only return SOM information under
an update lock?  I could maybe understand if there was some protocol
incompatibility, but the "size" parameter is already in the protocol and
is used by directories, and it would seem that clients that are not SOM-
aware would simply ignore that parameter (also, your client has to indicate
that at connection time, and the server code already knows about that
and acts accordingly).

This gets me into a related issue ... what, exactly, is the correct API to
use from a client side to lookup a file and get the right locks for it?
From what I see, clients use md_intent_lock() have a choice between using
an intent structure which has IT_LOOKUP or IT_GETATTR ... but looking
at the server code makes me think that other than the locking used, there
is no difference between these intents.  Is that accurate?

Lastly ... in the case where no SOM information is available, obviously
I need to fetch that information from the OSTs.  When I do that, is it
possible to do that under a lock as well so that information can be cached?
The only examples I can find in the client use obd_getattr_async(), and
that is (from what I can tell) _not_ a function which does locking.

--Ken
