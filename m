From: Andreas Dilger <adilger@whamcloud.com>
Date: Wed, 6 Nov 2019 10:48:20 +0000
Subject: [lustre-devel] trnasfer zfs record size to client
In-Reply-To: <1572973449.3824.0@informatik.uni-hamburg.de>
References: <1572973449.3824.0@informatik.uni-hamburg.de>
Message-ID: <F874D2F4-3092-49FA-8887-05DFD41A4E3B@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Nov 5, 2019, at 10:04, Anna Fuchs <anna.fuchs at informatik.uni-hamburg.de<mailto:anna.fuchs@informatik.uni-hamburg.de>> wrote:

Dear all,

for my work on the compression feature, I need the client to know the record size of the server/target (ZFS) where the request will be sent to. I assume there exist some communication channels between the client and the corresponding target for other options (like compatibility checking?). What would be the best way to tranfer this information?  Thanks for any hints.'

Hi Anna,
we pass the recordsize (or ldiskfs blcoksize) from each OST/MDT back to the client as part of struct obd_connect_data.

You can see this information in the "grant_block_size" field of osc.*.import for each OST.

Cheers, Andreas
--
Andreas Dilger
Principal Lustre Architect
Whamcloud






-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20191106/aa4bb939/attachment.html>
