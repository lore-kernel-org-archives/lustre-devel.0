From: Steve Allen <steve.allen@usherbrooke.ca>
Date: Wed, 11 Mar 2009 11:13:11 -0400
Subject: [Lustre-devel] kernel including perfctr
Message-ID: <49B7D507.4080101@usherbrooke.ca>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Since we had troubles compiling the Lustre source on our CentOS 
distribution with Infiniband, we installed the prepatched kernel.
Poorly this kernel does not have the Perfctr patch enabling measure of 
hardware performance with PAPI (http://icl.cs.utk.edu/papi/)

Can we expect, in a near future, that the Perfctr patch will be added to 
the kernel available from Lustre?

Steve Allen
HPC Analyst
CCS, RQCHP
Universite de Sherbrooke
