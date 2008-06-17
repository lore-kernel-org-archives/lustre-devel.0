From: Jakob Goldbach <jakob@goldbach.dk>
Date: Tue, 17 Jun 2008 20:54:39 +0200
Subject: [Lustre-devel] [Lustre-discuss] maximum MDT inode count
In-Reply-To: <20080617171058.GF3726@webber.adilger.int>
References: <20080617171058.GF3726@webber.adilger.int>
Message-ID: <1213728879.11174.21.camel@arven.one.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>   Otherwise,
> I think people would be interested to know what the larger MDT sizes
> are (even if they aren't as high as 2B inodes).
> 

I have three clusters of 400M inodes each. MDT formated with an inode
size of 256 and one inode per 1024 byte: '-I 256 -i 1024'. 

The cluster is split in three primarily to keep an eventual restore time
low but ideally this would be one big cluster with 1.2G inodes.

To other users: Note the inode size is less than recommended. My
stripecount is one so this is feasible without a performance hit but
Andreas warned me about future features which might add more user
attributes.  

/Jakob
