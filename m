From: Alex Zhuravlev <Alex.Zhuravlev@Sun.COM>
Date: Tue, 26 Jan 2010 13:02:32 +0300
Subject: [Lustre-devel] proposal on implementing a new readahead in clio
In-Reply-To: <4B56F907.3090308@sun.com>
References: <4B56F907.3090308@sun.com>
Message-ID: <4B5EBDB8.1030303@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi,

I think we could help a lot if you restructure the proposal a bit:

first of all, describe the algorithm w/o implementation details,
probably using notion of event: read event extending window, io to
get data ahead, read-ahead io completion, hit/miss, etc.

then map these events to specific code paths? explain what kind of
information/mechanism layers miss to implement the algorithm?

z.

On 1/20/10 3:37 PM, jay wrote:
> Hello,
>
> We have discussed the implementation of new readahead in CLIO. Here I
> just send the design document out to ask for comments.
>
> We have already had several inputs from Z(aka bzzz) and other engineers.
> I'm not going to copy those ideas here directly, because I'm afraid to
> distort something, so please reply this email to show your ideas -
> thanks in advance.
>
> Jay
>
>
>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
