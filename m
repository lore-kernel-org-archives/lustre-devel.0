From: Andreas Dilger <adilger@sun.com>
Date: Thu, 05 Feb 2009 17:01:28 -0700
Subject: [Lustre-devel] Oleg an Eric - Supporting >512 OSTs for Striping
In-Reply-To: <3F022A30-072C-4270-B83C-1DFBB4659D16@Sun.COM>
References: <C5B0A9CA.2F936%Daniel.Ferber@Sun.com>
	<1B98401E-C3F3-49C2-82F6-DE842B10858A@Sun.COM>
	<11f401c987d9$04d91b80$0e8b5280$@com>
	<678A8BA3-13B8-42E0-9CD6-57E084293AF0@Sun.COM>
	<20090205223154.GG3209@webber.adilger.int>
	<3F022A30-072C-4270-B83C-1DFBB4659D16@Sun.COM>
Message-ID: <20090206000128.GJ3209@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Feb 05, 2009  18:18 -0500, Oleg Drokin wrote:
> On Feb 5, 2009, at 5:31 PM, Andreas Dilger wrote:
>> we might consider to do MDS-originated object destroys for
>> such files (or all files) instead of sending huge RPC with cookies to
>> the client (~84kB reply).  These could be batched on unlink commit,  
>> and would also avoid the "inodes with destroyed objects" bug previously
>> discussed.
>
> Do you only think of this as a way to cut the maximum RPC reply size on 
> MDS?

Yes, if we don't have to return cookies to the unlinking client then
reply size will be ~ (24 * num_stripes) instead of (56 * num_stripes).

With SOM it may be that the client will have to pass cookies again,
though I'm not sure if that is for every OST in the file, or
only OSTs that the client wrote to.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
