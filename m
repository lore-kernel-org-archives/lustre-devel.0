From: Eric Barton <eeb@sun.com>
Date: Fri, 11 Jul 2008 10:05:02 +0100
Subject: [Lustre-devel] How store HSM metadata in MDT
In-Reply-To: <48761DB6.4010207@fnal.gov>
References: <48761DB6.4010207@fnal.gov>
Message-ID: <00d001c8e335$341ff2e0$0281a8c0@ebpc>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

> For Lustre HSM project, it will be needed to store, for each file, a 
> list of information describing how many copies the file has in the HSM, 
> what is their HSM ID, the copy date, and so on. This data could easily 
> reach 500 bytes (I think we will need between 40 and 50 bytes per HSM 
> copy, and we should be able to save at least 10 copies, surely more).
> The question is: where could we store this data on MDT, in which place 
> (EA?) and how manage this.

Storing information about > 1 HSM copy violates one of our groundrules...

> 3. The file system only has attributes to indicate the state of the primary
> archived copy (probably the last fully archived copy of the file), and can
> retrieve that file on demand (without user intervention).

    Cheers,
              Eric
