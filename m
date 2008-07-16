From: Jacques-Charles Lafoucriere <jc.lafoucriere@cea.fr>
Date: Wed, 16 Jul 2008 12:26:20 +0200
Subject: [Lustre-devel] How store HSM metadata in MDT ?
In-Reply-To: <C49D336A.63D9%peter.braam@sun.com>
References: <C49D336A.63D9%peter.braam@sun.com>
Message-ID: <487DCCCC.7060206@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Space Manager needs are:
1) generate a candidate list for copy out (pre-migration)
2) generate a candidate list for purge

For 1) the criteria is : not up to date in HSM and not recently modified
For 2) the criteria is : up to date in HSM and not recently accessed

Needed changelogs events are "modifications" like :
- file creation
- mtime change
- atime change

The things I do not like in events mode are:
- if a file is created, filled and remove before copy-out (like a 
temporary file), we will have useless interaction with the spacemanger 
(and useless load)
- if for some issue, events are missed we will have HSM unknown files in 
Lustre. To resume this issue we can use a scan or find a way to warranty 
we will never missed an event.
This last point is a strong constraint because Lustre should be able to 
operate with a dead space manager.

I agree, I not fond of scanning, but  a low priority, background scan 
will solve these 2 issues.

For me the spacemanager and it's DB are common to all HSM and will have 
no HSM specific information.
HSM specific rules (like in which HSM internal storage class I will put 
a file) will be managed by HSM copy tool
Do you agree ?

JC
