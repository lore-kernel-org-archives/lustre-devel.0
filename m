From: Eric Barton <eeb@sun.com>
Date: Tue, 11 Aug 2009 16:55:39 +0200
Subject: [Lustre-devel] Role of the Metadata Server during File I/O
In-Reply-To: <20090810223137.E018520DBF8C@hailoo.com>
References: <20090810223137.E018520DBF8C@hailoo.com>
Message-ID: <034001ca1a93$cd8ec140$68ac43c0$@com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The file size is computed from the sizes of all its stripes to avoid

unnecessary communication with the MDS while a file is being

extended.

 

Obviously the next question is ?does that mean you have to consult all

the OSTs whenever you stat a file?? and currently the answer is yes.

However we are developing a new feature to allow Lustre to cache the

sizes of inactive files on the MDS to give us the best of both worlds.

Cheers, 
                   Eric 

 

From: lustre-devel-bounces@lists.lustre.org [mailto:lustre-devel-bounces at lists.lustre.org] On Behalf Of office at hailoo.com
Sent: 11 August 2009 12:32 AM
To: lustre-devel at lists.lustre.org
Subject: [Lustre-devel] Role of the Metadata Server during File I/O

 

One of Lustre's key innovations seems to be the separation of metadata from file data.  According to Sun, "Lustre file operations bypass the MetaData server completely and fully utilize the parallel data paths to all OSSs in the cluster."  (See http://www.sun.com/software/products/lustre/features.xml) 

However, can this really be the case? 

In POSIX-compliant file I/O, a call to write() that starts at an offset which is greater than the file size must write zeroes to disk to make up for the missing space.  So if you have a file size of 0 bytes, and then you write a single byte at offset 10, bytes 0 through 9 of the file will contain zeros.  

But if a file on a Lustre system is striped across multiple OSTs, how does Lustre avoid communicating with the Metadata Server at every write operation?  Consider the following scenario: 

You have 4 OSTs and you create a new file and stripe it across all 4 OSTs, and you set the stripe size to 4 bytes.  (I know that is too small but I'm just keeping this simple.) 

Now, suppose you call write() and write 1 byte to the file at offset 5.  Lustre must now write 4 zero bytes on the first OST, and 1 non-zero byte on the second OST.  But in order to know that it is necessary to write zeroes to the first OST, the client would need access to global information about the total size of the file.  Therefore, wouldn't it need to check with the Metadata Server to determine the total file size before every call to write()? 

Any information anyone can provide me on the implementation details/strategies used here would be greatly appreciated. 

-Charles Salvia 

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20090811/38e6b897/attachment.htm>
