From: Peter Braam <Peter.Braam@Sun.COM>
Date: Fri, 11 Jul 2008 15:57:30 -0600
Subject: [Lustre-devel] How store HSM metadata in MDT ?
In-Reply-To: <48776ECD.3000501@cea.fr>
Message-ID: <C49D336A.63D9%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

A one time event to build a database or log is acceptable.

However, the proposal so far would require frequent scans because the
metadata would be in the wrong place, that is what I want to avoid.

Maintaining that metadata is very simple, and can solve some problems that
you cannot easily solve without maintaining a database in conjunction with
the HSM (such as cleaning partial, aborted copies into the HSM).  You?d
simply ask the moving script to contact a database and make a record.  The
database may not be able to keep up with all file creations in the FS but it
can probably keep up with the activities that one moving node does to/from
the HSM.

Peter


On 7/11/08 8:31 AM, "Jacques-Charles Lafoucriere" <jc.lafoucriere@cea.fr>
wrote:

> 
> 
> Peter Braam wrote:
>>  
>> 
>> There is a rule in Lustre - no scanning, ever.  This rule will not be broken
>> by HSM.  
>>   
> If a site wants to connect an HSM to an existing file system (close to be
> full)
> how do we do without fast scanning ?
> We cannot restrict the use of HSM binding only on new file systems
> 
> JC
> 

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080711/61dbfe02/attachment.htm>
