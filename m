From: Bradley W. Settlemyer <settlemyerbw@ornl.gov>
Date: Thu, 15 Oct 2009 14:52:02 -0400
Subject: [Lustre-devel] max_dirty_mb and fsync
Message-ID: <4AD76F52.4040706@ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello

   What is the difference between setting the max_dirty_mb setting in 
/proc to 4 and making sure that all of my applications fsync every 4MBs 
of data that are transmitted?

   I would guess that one difference is the 32MB is a filesystem-wide 
setting rather than a per file setting -- so the sync occurs regardless 
of the number of files receiving data.  But are there any other 
differences with regards to the interaction with the file system.

   More to the point perhaps, does an fsync have additional side effects 
beyond those that occur for the max_dirty_mb threshhold being exceeded?

Cheers,
Brad
