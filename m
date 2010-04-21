From: Andreas Dilger <andreas.dilger@oracle.com>
Date: Wed, 21 Apr 2010 15:04:58 -0600
Subject: [Lustre-devel] Flush on file close
In-Reply-To: <32DB67DD-B971-408E-8CD7-6B10344D7576@oracle.com>
References: <201004192230.48196.andrew.perepechko@sun.com>
	<5395043C-A24E-46B0-9E63-5F4DB570DDFD@oracle.com>
	<32DB67DD-B971-408E-8CD7-6B10344D7576@oracle.com>
Message-ID: <391C7149-1E61-417C-AE40-EA172813778F@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2010-04-19, at 23:16, Oleg Drokin wrote:
> Actually this is already being done. We do set AS_error (or something like that).  There is only one exception where on eviction we forgot to implement this, I think.

One thing I see in both the 1.x and 2.x client code is that even though we track the errors from async file IO on the file descriptor, we don't actually return them to the application at close time:

ll_file_release()
{
        if (lsm)
                lov_test_and_clear_async_rc(lsm);
        lli->lli_async_rc = 0;     

It looks like this should be something like:

        if (lsm)
                rc2 = lov_test_and_clear_async_rc(lsm);
        if (rc2 == 0)
                rc2 = lli->lli_async_rc;     
        lli->lli_async_rc = 0;
   
> On Apr 19, 2010, at 10:34 PM, Andreas Dilger wrote:
> 
>> One thing we can do to improve this situation a bit is to return any  
>> previous write error codes at close time.
>> 
>> Cheers, Andreas
>> 
>> On 2010-04-19, at 12:30, Andrew Perepechko <Andrew.Perepechko@Sun.COM>  
>> wrote:
>> 
>>> Some applications expect non-zero errno on close() for any errors  
>>> that may
>>> happen during flushing dirty cached data/metadata even though linux  
>>> manual
>>> page for close(2) suggests that fsync(2) should be used prior to  
>>> close(2) in
>>> order to detect problems like those.
>>> 
>>> Since syncing may degrade performance to a large extent, what do you  
>>> think is
>>> the best/most convenient/least intrusive way to switch to that  
>>> behaviour?
>>> Should it be a mount option for the client or anything else?
>>> 
>>> Andrew.
>>> _______________________________________________
>>> Lustre-devel mailing list
>>> Lustre-devel at lists.lustre.org
>>> http://lists.lustre.org/mailman/listinfo/lustre-devel
>> _______________________________________________
>> Lustre-devel mailing list
>> Lustre-devel at lists.lustre.org
>> http://lists.lustre.org/mailman/listinfo/lustre-devel
> 


Cheers, Andreas
--
Andreas Dilger
Principal Engineer, Lustre Group
Oracle Corporation Canada Inc.
