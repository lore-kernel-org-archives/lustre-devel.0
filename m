From: Oleg Drokin <oleg.drokin@oracle.com>
Date: Tue, 20 Apr 2010 15:57:37 -0400
Subject: [Lustre-devel] Flush on file close
In-Reply-To: <8AE7A7A2-C300-4E9F-908A-0996804242F8@oracle.com>
References: <201004192230.48196.andrew.perepechko@sun.com>
	<5395043C-A24E-46B0-9E63-5F4DB570DDFD@oracle.com>
	<32DB67DD-B971-408E-8CD7-6B10344D7576@oracle.com>
	<72C27251-2B14-48FE-BDD0-8B5252C7957A@earthlink.net>
	<8AE7A7A2-C300-4E9F-908A-0996804242F8@oracle.com>
Message-ID: <A07310FC-CD6C-463D-9996-847ABA6273A8@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

> It's all internal within NFS. There is no way for the client to say
> "these writes are async", "now do commit" aside from

I meant to say "no way for the application" here.
