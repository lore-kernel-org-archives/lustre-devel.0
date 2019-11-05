From: Anna Fuchs <anna.fuchs@informatik.uni-hamburg.de>
Date: Tue, 05 Nov 2019 18:04:09 +0100
Subject: [lustre-devel] trnasfer zfs record size to client
Message-ID: <1572973449.3824.0@informatik.uni-hamburg.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Dear all,

for my work on the compression feature, I need the client to know the 
record size of the server/target (ZFS) where the request will be sent 
to. I assume there exist some communication channels between the client 
and the corresponding target for other options (like compatibility 
checking?). What would be the best way to tranfer this information?  
Thanks for any hints.

Best regards
Anna

-- 
Uni Hamburg
<https://wr.informatik.uni-hamburg.de/people/anna_fuchs>


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20191105/7b57f2f0/attachment.html>
