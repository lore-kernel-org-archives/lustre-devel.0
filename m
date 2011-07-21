From: John Hammond <jhammond@tacc.utexas.edu>
Date: Thu, 21 Jul 2011 15:15:14 -0500
Subject: [Lustre-devel] open(), getattr(), and negative dentries
Message-ID: <4E2888D2.7090201@tacc.utexas.edu>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Dear Lustre-devel,

It appears that stating a non-existent file on Lustre causes a negative
dentry to be created, while opening it does not.  If I understand
correctly, this also means that every open of a non-existent file that
misses the dentry cache causes an RPC to the MDS.  Is there a reason for
the difference?

Thanks,

John

-- 
John L. Hammond
TACC, The University of Texas at Austin
jhammond at tacc.utexas.edu
