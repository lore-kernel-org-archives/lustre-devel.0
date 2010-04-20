From: Oleg Drokin <oleg.drokin@oracle.com>
Date: Tue, 20 Apr 2010 15:46:49 -0400
Subject: [Lustre-devel] Flush on file close
In-Reply-To: <72C27251-2B14-48FE-BDD0-8B5252C7957A@earthlink.net>
References: <201004192230.48196.andrew.perepechko@sun.com>
	<5395043C-A24E-46B0-9E63-5F4DB570DDFD@oracle.com>
	<32DB67DD-B971-408E-8CD7-6B10344D7576@oracle.com>
	<72C27251-2B14-48FE-BDD0-8B5252C7957A@earthlink.net>
Message-ID: <8AE7A7A2-C300-4E9F-908A-0996804242F8@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Apr 20, 2010, at 3:56 AM, Mitchell Erblich wrote:

> 			NFS allows async writes and then commits.

It's all internal within NFS. There is no way for the client to say
"these writes are async", "now do commit" aside from
doing manual syncs for commits and using some sort of sync io open flags
to force "sync" writes.
Of course additional level of confusion is the "async writes" you reference
have nothing to do with real write system calls. In fact write system calls
put data in memory and data might stay there for who knows how long
(or until close) and only when NFS client decides (or VFS forces it to)
to write the data to the server is when these "async writes" are used,
Lustre has this too.

> 			I would almost suggest this..

It's already implemented sort of NFS-style except the close-to-open.

> 			As yes, close's are not expected to fail.

Huh?!

> 			What would you do / should you do if a close failed?

Well, you assume the file content is no longer correct and write it again, I guess.
Or if you are like 99% of people writing programs out there, you just bail out with an error ;)

Bye,
    Oleg
