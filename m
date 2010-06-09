From: Ken Hornstein <kenh@cmf.nrl.navy.mil>
Date: Wed, 09 Jun 2010 12:42:29 -0400
Subject: [Lustre-devel] Attribute caching and OBD_CONNECT_ATTRFID
Message-ID: <201006091642.o59GgTll020727@hedwig.cmf.nrl.navy.mil>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

So I've been working on attribute caching for Lustre for the MacOS X port,
and I've run into a bit of a snag.

A bit of a brief explanation: unlike Linux, where (as I understand it)
filesystems have to store attributes in the vnode as they change, on
BSD-derived vnode filesystems you have a getattr function that gets
called to find out the attributes of a file.  You get passed a pointer
to the vnode (a sort-of virtual inode) and in that contains a pointer
to a structure which the filesystem manages; in Lustre's case, that
contains among other things a copy of the FID.  So just to recap, when
MacOS X wants the attributes of a file, it's done via FID, not by
filename.  I am aware that you can get attributes at lookup time, and I
plan on implementing that, but I figure I'd start with this first.

It is my understanding that to properly implement attribute caching, I
need to call md_intent_lock with the right op_data and an intent
structure with it_op set to IT_GETATTR.  When those attributes change,
I'll get notified in my ast callback.  If that's wrong, then please
correct me.

First off, I see that one of the options at connect time is
OBD_CONNECT_ATTRFID, and looking at the comments and the llite code for
this option it seems pretty self explanatory - you can fetch file
attributes by FID.  Perfect!  Well, like the llite code I test to make
sure OBD_CONNECT_ATTRFID is set in the connect flags, and I discover
that it is _not_.

The reason for this is that it's commented out of the
MDT_CONNECT_SUPPORTED macro in lustre_idl.h (and that's used to mask
out the reply you get indicating what is supported).  Now, it's not
clear to me why that was done: this happened back in 2007 as part of
commit d2d56f38, and the commit entry just says, "make HEAD from
b_post_cmd3", and it's been that way ever since.

The code still seems to exist on the server, so I figure I'll give it
a try anyway,  First issue: you need to include the parent when using
CONNECT_ATTRFID; I have to confess that I don't understand why, because
you would think that it wouldn't be necessary just to get the attributes
for a file, but this in enforced on the server (unfortunately, by
kicking an LBUG).  This is a problem for the root directory since it's
the first one looked up _and_ it doesn't have a parent, but I can special
case that; for all other vnodes, the parent is easy to find (the filesystem
layer keeps track of it).

When I try doing _that_, I get an error from the lmv routines that I haven't
tracked down yet.  But the whole thing makes me wonder if perhaps I'm
doing the wrong thing.

From what I see, attributes are also cached at open/lookup time and as
part of the statahead code; I can do that relatively easy.  But if
attributes _change_, then I have to wonder what is supposed to happen
next.  Since current Lustre servers don't return OBD_CONNECT_ATTRFID as
being set anymore, the code in the client doesn't seem like it will
cache the attribute (for files, anyway) anymore.  It's entirely possible 
that I'm missing something; that happens a lot.

So, I guess the question I have is ... if you get your lock broken when
you have it on a file's attributes, exactly what is supposed to happen next?
What's the mechanism for getting it again?

--Ken
