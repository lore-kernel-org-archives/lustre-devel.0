From: Alexander Moibenko <moibenko@fnal.gov>
Date: Thu, 10 Jul 2008 09:33:26 -0500
Subject: [Lustre-devel] How store HSM metadata in MDT
Message-ID: <48761DB6.4010207@fnal.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

------------------------------------------------------------
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
---------------------------------------------
Hi Aurelien,
I have just subscribed to the list this is why my reply has an unusual format.
We at FNAL are considering to integrate lustre with our multipetabyte storage system Enstore: http://www-ccf.fnal.gov/enstore/
We had a preliminary discussion and some feasibility study and think that EA would be a good match. 
We though that it would be enough to have HSM ID(s) stored as EA the rest can be fetched directly from HSM referred by ID(s).
Thanks,

-- 
--------------------------------------------
Alexander N. Moibenko, Ph.D., CD, Fermilab
Tel: (630)840-3937 email: moibenko at fnal.gov
--------------------------------------------
