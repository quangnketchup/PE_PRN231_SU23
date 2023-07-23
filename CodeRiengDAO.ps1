#DataAccess--------------------------------------------------------------------------------------------
cd DataAccess
#Create class DataAccess.PetDao ============================================================== TODO
@"
using BusinessObject.Model;
using Microsoft.EntityFrameworkCore;
using System.Net;
using static DataAccess.GlobalExceptionHandler.ExceptionResponse;

namespace DataAccess
{
    public class PetDao
    {
        //Using Singleton Pattern
        private static PetDao? instance = null;
        private static readonly object instanceLock = new();
        private PetDao() { }
        public static PetDao Instance
        {
            get
            {
                lock (instanceLock)
                {
                    instance ??= new PetDao();
                    return instance;
                }
            }
        }

        public List<Pet> GetAll()
        {
            var employees = new List<Pet>();
            try
            {
                using var context = new PetShop2023DBContext(); //=================DbContext
                employees = context.Pets.Include(x => x.PetGroup).ToList();//=================Change x.PetGroup
            }
            catch (Exception ex)
            {
                throw new HttpStatusException(HttpStatusCode.InternalServerError, ex.Message);
            }
            return employees;
        }

        public Pet Get(int id)
        {
            Pet? pet;
            try
            {
                using var contect = new PetShop2023DBContext(); //===================================DbContext
                pet = contect.Pets.Include(x => x.PetGroup).SingleOrDefault(x => x.PetId == id); //=================Change x.PetGroup

                if (pet == null)
                {
                    throw new HttpStatusException(HttpStatusCode.NotFound, "Pet Id Not Found!");
                }
            }
            catch (Exception ex)
            {
                throw new HttpStatusException(HttpStatusCode.InternalServerError, ex.Message);
            }

            
            return pet;
        }

        public void Add(Pet pet)
        {
            using var context = new PetShop2023DBContext();//===================================DbContext
            PetGroup? petgroup = context.PetGroups.FirstOrDefault(x => x.PetGroupId == pet.PetGroupId); //============Change x.PetGroup
            if (petgroup == null)
            {
                throw new HttpStatusException(HttpStatusCode.BadRequest, "Pet Group Id not Exist!");
            }

            Pet? p = context.Pets.Include(x => x.PetGroup).SingleOrDefault(x => x.PetId == pet.PetId); //============Change x.PetGroup
            if (p == null)
            {
                context.Pets.Add(pet);
                context.SaveChanges();
            }
            else
            {
                throw new HttpStatusException(HttpStatusCode.NotFound, "Pet Id is Exist!");
            }
        }

        public void Edit(Pet pet)
        {
            using var context = new PetShop2023DBContext();//===================================DbContext
            var petgroup = context.PetGroups.SingleOrDefault(x => x.PetGroupId == pet.PetGroupId);//============Change x.PetGroup
            if (petgroup == null)
            {
                throw new HttpStatusException(HttpStatusCode.NotFound, "Pet Group Id Not Found!");
            }

            var emp = Get(pet.PetId);
            if (emp != null)
            {
                try
                {
                    context.Entry<Pet>(pet).State = EntityState.Modified;
                    context.SaveChanges();
                }
                catch (Exception ex)
                {
                    throw new HttpStatusException(HttpStatusCode.InternalServerError, ex.Message);
                }
            }
            else
            {
                throw new HttpStatusException(HttpStatusCode.NotFound, "Pet Id Not Found!");
            }
        }

        public void Delete(int id)
        {
            var pet = Get(id);
            if (pet != null)
            {
                using var context = new PetShop2023DBContext();//===================================DbContext
                context.Pets.Remove(pet);
                context.SaveChanges();
            }
            else
            {
                throw new HttpStatusException(HttpStatusCode.NotFound, "Pet Id Not Found!");
            }
        }
    }
}
"@ | Set-Content -Path "PetDao.cs"
cd ..
