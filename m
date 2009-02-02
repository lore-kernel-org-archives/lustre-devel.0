From: Colin Ngam <Colin.Ngam@Sun.COM>
Date: Mon, 02 Feb 2009 14:42:36 -0600
Subject: [Lustre-devel] Lustre HSM - some talking points.
In-Reply-To: <49874F5E.6030203@ornl.gov>
References: <3DF0F4AF-F4D6-476E-98F7-CD912C49FC18@Sun.COM>
	<2734A30F-2C76-4725-9F3A-29AD4245B7E8@Sun.COM>
	<496FCA67.6000500@sun.com>
	<48D329C0-242E-4A5A-94C1-DF493BB25C2F@Sun.COM>
	<496FE8D4.2090908@sun.com>
	<BEB67402-7AFE-4BE1-A59C-050823AFC8E5@Sun.COM>
	<4977647D.5010503@sun.com>
	<4977E5BD.7000706@sun.com> <4978DB1E.30507@sun.com>
	<497A144C.4000408@Sun.COM>
	<20090126193548.GF3652@webber.adilger.int> <497E35A3.3080603@sun.com>
	<DEB5E509-4641-40B6-86CA-972D885975D3@Sun.COM>
	<4983998D.1030601@sun.com>
	<8585251D-41D7-4B42-99F9-BDBFA2CF88C1@Sun.COM> <4987098F.402@Sun.COM>
	<367E32B4-A759-45AD-9D2C-48C051FE1D62@Sun.COM>
	<49872C9B.7060708@Sun.COM>
	<498734AA.7010704@ornl.gov> <4987489D.4050909@Sun.COM>
	<49874F5E.6030203@ornl.gov>
Message-ID: <49875ABC.8000400@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Vicky White wrote:

Hi Vicky,
> Colin Ngam wrote:
>> I do not see why we need to query these EAs in normal operation.  
>> These EAs will only be accessed when we need to perform Ultimate 
>> Disaster Recovery - when you have lost all data on disks and all you 
>> have are tapes.
>
>
> That would help.  I don't know what it would cost to store the EA in a 
> separate object to begin with, though, and that would be incurred on 
> every file.   Plus you have to consider the space it takes up.
>
>
>> I was thinking about XML - but it is "opaque" to Object SAMQFS so, it 
>> is up to the Lustre side.  Whatever it is, the Applications - 
>> Lustre-Restore for example, is the one that has to understand the 
>> format.  I am not a Tar Header expert - but I assume that these EAs 
>> can go with the file in the tar ball.
>
>
> I think what you put in the tar ball is up to you.   Putting the EAs 
> in there regardless of what the hsm was might simplify the design, so 
> you wouldn't have to extract the EA in a different way for each hsm.
>
> I was just trying to keep the hpss EA design in front of folks so that 
> if we were considering using that, we knew all the tradeoffs.
Good point.  I guess EA can be anywhere in the tar file, but, best if 
somehow it is put together for fast access.  But then, we do not need it 
unless it is for Ultimate Disaster Recovery .. that should never happen :-))

With respect to space - how about compression?  The problem is, I always 
thought space is cheap.  Does HPSS ever scrub/recycle?  Policy driven?

If EAs are going to be in a Database, I can see it can be a problem.

Path name does not need to be in the EA.  It is needed for the tar 
header only.  I guess the EA will consist of everything that Lustre 
needs to restore a file, completely.
>
>
>> I do not expect to keep any of it on line on disk cache, on the SAMFS 
>> side.  I see no reason.
>>
>> With respect to whether it should be consistent with HPSS - I would 
>> say if that is all we need and it is sufficient - why not.  
>> Otherwise, let's make it better than HPSS.  It must be in SUN's best 
>> interest to sell SAMQFS?
>
>
> Oh, I'm sure it is.
>
>
>> I do apologize Vicky, are you a SUN employee?
>
>
> No.   Were you going to feel sorry for me if I worked for Sun? ;)
No, it's kind of fun to design with .. and I want to say competitor, but 
I guess you do not really fall into that category.  Say hi to Kim K. or 
Dave W(Cray folks) for me if they cross your path.
>
>
> Vicky
>
PS-The programmer's reference is close to 400 pages!  Perhaps I should 
start with User's Guide.
