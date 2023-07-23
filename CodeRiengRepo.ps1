cd Repositories


# IPetRepository =============================================================================== TODO
@"
using BusinessObject.Model;

namespace Repositories
{
    public interface IPetRepository
    {
        List<Pet> GetAll();
        Pet Get (int id);
        void Add(Pet pet);
        void Update(Pet pet);
        void Delete(int id);
    }
}
"@ | Set-Content -Path "IPetRepository.cs"

#Repository
# PetRepository =============================================================================== TODO
@"
using BusinessObject.Model;
using DataAccess;

namespace Repositories
{
    public class PetRepository : IPetRepository
    {
        public void Add(Pet pet)
        {
            PetDao.Instance.Add(pet);
        }

        public void Delete(int id)
        {
            PetDao.Instance.Delete(id);
        }

        public Pet Get(int id)
        {
            return PetDao.Instance.Get(id);
        }

        public List<Pet> GetAll()
        {
            return PetDao.Instance.GetAll();
        }

        public void Update(Pet pet)
        {
            PetDao.Instance.Edit(pet);
        }
    }
}
"@ | Set-Content -Path "PetRepository.cs"
cd ..