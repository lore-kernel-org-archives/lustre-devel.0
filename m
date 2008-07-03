From: Aurelien Degremont <aurelien.degremont@cea.fr>
Date: Thu, 03 Jul 2008 13:43:21 +0200
Subject: [Lustre-devel] How store HSM metadata in MDT ?
Message-ID: <486CBB59.4080206@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

HSM MetaData

For Lustre HSM project, it will be needed to store, for each file, a 
list of information describing how many copies the file has in the HSM, 
what is their HSM ID, the copy date, and so on. This data could easily 
reach 500 bytes (I think we will need between 40 and 50 bytes per HSM 
copy, and we should be able to save at least 10 copies, surely more).
The question is: where could we store this data on MDT, in which place 
(EA?) and how manage this.

We had a discussion about this with Andreas and Nathan and it is not 
very clear what is the best solution here regarding to:
- We must keep in mind that there is 2 available backends for MDT: 
ldiskfs and ZFS and both must be supported here.
- EA space is not very wide on ldiskfs and quite used by several other 
features (stripping, ACL, ...)
- Clients will need to read this data and so the RPC mechanism should be 
available and large enough to handle it.

Moreover, we will store a purged data range on OST and MDT. This could 
easily fit in a EA.

What is the possible solutions we have here ?

-- 
Aurelien Degremont
CEA
